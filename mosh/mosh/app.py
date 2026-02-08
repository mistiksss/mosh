from flask import Flask, render_template, redirect, url_for, request, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from flask_login import (
    UserMixin, login_user, LoginManager,
    login_required, logout_user, current_user
)
from sqlalchemy.dialects.postgresql import ARRAY
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import InputRequired, Length, ValidationError, Email, EqualTo
from flask_bcrypt import Bcrypt
from datetime import datetime, timedelta
from sqlalchemy import cast
from sqlalchemy.dialects import postgresql
import csv
import io

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:54321@localhost:5432/schoolfood'
app.config['SECRET_KEY'] = "ea895771cd548603ffeb0f919568488deede3e855285883bb5c55c6b484c13cc"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_recycle': 300,
    'pool_pre_ping': True,
}
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.init_app(app)

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(70), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False, default="student")  # student/cook/admin
    balance = db.Column(db.Integer, default=0)
    sub_until = db.Column(db.DateTime, nullable=True)
    allergens = db.Column(ARRAY(db.String), nullable=False, default=list)
    created_at = db.Column(db.DateTime, server_default=db.func.now())


class Dish(db.Model):
    __tablename__ = "dishes"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    short_desc = db.Column(db.String(256), nullable=False)
    description = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(20), nullable=False)  # breakfast / lunch
    price = db.Column(db.Integer, nullable=False)
    image_url = db.Column(db.Text, nullable=False)
    kcal = db.Column(db.Integer, nullable=False)
    protein = db.Column(db.Integer, nullable=False)
    fat = db.Column(db.Integer, nullable=False)
    allergens = db.Column(ARRAY(db.String), nullable=False, default=list)
    carbs = db.Column(db.Integer, nullable=False)



class Product(db.Model):
    """Складские остатки для панели повара."""
    __tablename__ = "products"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), unique=True, nullable=False)
    quantity = db.Column(db.Float, nullable=False, default=0.0)      # числовое значение
    unit = db.Column(db.String(20), nullable=False, default="шт")    # 'кг'/'л'/'шт' и т.п.
    min_quantity = db.Column(db.Float, nullable=False, default=0.0)

class Order(db.Model):
    __tablename__ = "orders"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    dish_id = db.Column(db.Integer, db.ForeignKey("dishes.id"), nullable=False)
    status = db.Column(db.String(20), nullable=False, default="preparing")
    is_free = db.Column(db.Boolean, default=False)
    price_paid = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    user = db.relationship("User", backref="orders")
    dish = db.relationship("Dish", backref="orders")


 # ---- ADMIN / ACCOUNTING MODELS ----

class Payment(db.Model):
    """Факты оплат и списаний для аналитики администратора."""
    __tablename__ = "payments"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    # В этой базе данных уже есть обязательный столбец payments.type (NOT NULL).
    # Чтобы INSERT не падал, заполняем его всегда.
    type = db.Column(db.String(32), nullable=False, server_default="topup")
    direction = db.Column(db.String(8), nullable=False, server_default="in")  # in / out
    kind = db.Column(db.String(32), nullable=False)      # topup/subscription/order/expense
    amount = db.Column(db.Integer, nullable=False)       # всегда положительное число
    note = db.Column(db.String(256), nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    user = db.relationship("User", backref="payments")


class Attendance(db.Model):
    """Посещаемость: один факт на пользователя в день."""
    __tablename__ = "attendance"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    day = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    user = db.relationship("User", backref="attendance")
    __table_args__ = (db.UniqueConstraint('user_id', 'day', name='uq_attendance_user_day'),)


class PurchaseRequest(db.Model):
    """Заявки на закупку (создает повар, согласует администратор)."""
    __tablename__ = "purchase_requests"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=True)
    amount = db.Column(db.Integer, nullable=False)
    status = db.Column(db.String(20), nullable=False, default="pending", server_default="pending")  # pending/approved/rejected
    created_by = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    decided_by = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    decided_at = db.Column(db.DateTime, nullable=True)
    creator = db.relationship("User", foreign_keys=[created_by], backref="purchase_requests")
    decider = db.relationship("User", foreign_keys=[decided_by])


class Expense(db.Model):
    """Расход (обычно создается автоматически при одобрении заявки)."""
    __tablename__ = "expenses"
    id = db.Column(db.Integer, primary_key=True)
    purchase_request_id = db.Column(db.Integer, db.ForeignKey("purchase_requests.id"), nullable=True)
    category = db.Column(db.String(50), nullable=False, default="food", server_default="food")
    amount = db.Column(db.Integer, nullable=False)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    pr = db.relationship("PurchaseRequest", backref="expense")


@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))

class RegisterForm(FlaskForm):
    username = StringField(validators=[InputRequired(), Length(min=4, max=20)])
    email = StringField(validators=[InputRequired(), Email(), Length(max=70)])
    password = PasswordField(validators=[InputRequired(), Length(min=6, max=30)])
    confirm_password = PasswordField(validators=[
        InputRequired(),
        EqualTo('password', message='Пароли не совпадают')
    ])
    submit = SubmitField("Зарегистрироваться")

    def validate_username(self, username):
        existing = User.query.filter_by(username=username.data).first()
        if existing:
            raise ValidationError("Это имя пользователя уже занято.")

    def validate_email(self, email):
        existing = User.query.filter_by(email=email.data).first()
        if existing:
            raise ValidationError("Этот email уже зарегистрирован.")


class LoginForm(FlaskForm):
    email = StringField(validators=[InputRequired(), Email(), Length(max=70)])
    password = PasswordField(validators=[InputRequired(), Length(min=6, max=30)])
    submit = SubmitField("Войти")

def require_role(role: str):
    return current_user.is_authenticated and current_user.role == role

def has_subscription(user: User):
    return user.sub_until and user.sub_until > datetime.utcnow()

@app.route("/")
def index():
    return redirect(url_for("login"))

@app.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data.strip()).first()
        if user and bcrypt.check_password_hash(user.password_hash, form.password.data):
            login_user(user)

            if user.role == "student":
                return redirect(url_for("main_student"))
            elif user.role == "cook":
                return redirect(url_for("main_cook"))
            elif user.role == "admin":
                return redirect(url_for("main_admin"))
            else:
                return redirect(url_for("main_student"))

        form.email.errors.append("Неверный email или пароль.")

    return render_template("login.html", form=form)

@app.route("/orders_student")
@login_required
def orders_student():
    if not require_role("student"):
        return redirect(url_for("login"))

    orders = (Order.query
              .filter_by(user_id=current_user.id)
              .order_by(Order.created_at.desc())
              .all())

    return render_template(
        "orders_student.html",
        student_name=current_user.username,
        balance=current_user.balance,
        has_sub=has_subscription(current_user),
        orders=orders
    )


@app.post("/api/orders/<int:order_id>/pick")
@login_required
def api_pick_order(order_id):
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа"), 403

    order = Order.query.filter_by(id=order_id, user_id=current_user.id).first()
    if not order:
        return jsonify(ok=False, error="Заказ не найден"), 404

    if order.status != "ready":
        return jsonify(ok=False, error="Заказ еще не готов"), 400

    order.status = "picked"

    # посещаемость: фиксируем факт посещения на дату получения заказа
    day = datetime.utcnow().date()
    exists = Attendance.query.filter_by(user_id=current_user.id, day=day).first()
    if not exists:
        db.session.add(Attendance(user_id=current_user.id, day=day))
    db.session.commit()
    return jsonify(ok=True)

@app.post("/api/cook/orders/<int:order_id>/done")
@login_required
def api_cook_done(order_id):
    if not require_role("cook"):
        return jsonify(ok=False, error="Нет доступа"), 403

    order = Order.query.get(order_id)
    if not order:
        return jsonify(ok=False, error="Заказ не найден"), 404

    if order.status != "preparing":
        return jsonify(ok=False, error="Нельзя изменить статус"), 400

    order.status = "ready"
    db.session.commit()
    return jsonify(ok=True)



@app.get("/api/cook/orders")
@login_required
def api_cook_orders():
    if not require_role("cook"):
        return jsonify(success=False, error="Нет доступа"), 403

    pending = (Order.query
               .filter(Order.status.in_(["preparing", "ready"]))
               .order_by(Order.created_at.asc())
               .all())

    issued = (Order.query
              .filter(Order.status == "picked")
              .order_by(Order.created_at.desc())
              .limit(200)
              .all())

    def _fmt(o: Order):
        issued_dt = o.created_at or datetime.utcnow()
        return {
            "id": str(o.id),
            "name": o.dish.name if o.dish else f"Блюдо #{o.dish_id}",
            "issued": (o.status == "picked"),
            "issuedTime": issued_dt.strftime("%H:%M"),
            "issuedDate": issued_dt.strftime("%d.%m.%Y"),
        }

    return jsonify(
        pending=[{"id": str(o.id), "name": o.dish.name if o.dish else f"Блюдо #{o.dish_id}", "issued": False} for o in pending],
        issued=[_fmt(o) for o in issued],
    )


@app.post("/api/cook/orders/issue")
@login_required
def api_cook_issue():
    if not require_role("cook"):
        return jsonify(success=False, error="Нет доступа"), 403

    data = request.get_json(silent=True) or {}
    order_id = data.get("orderId")
    try:
        order_id_int = int(order_id)
    except Exception:
        return jsonify(success=False, error="Некорректный orderId"), 400

    order = Order.query.get(order_id_int)
    if not order:
        return jsonify(success=False, error="Заказ не найден"), 404

    if order.status == "picked":
        return jsonify(success=True, order={"id": str(order.id), "name": order.dish.name}, message="Уже выдано")

    # выдача блюда: фиксируем как 'picked'
    order.status = "picked"

    # фикс посещаемости на клиента (один раз в день)
    day = datetime.utcnow().date()
    exists = Attendance.query.filter_by(user_id=order.user_id, day=day).first()
    if not exists:
        db.session.add(Attendance(user_id=order.user_id, day=day))

    db.session.commit()

    issued_order = {
        "id": str(order.id),
        "name": order.dish.name if order.dish else f"Блюдо #{order.dish_id}",
        "issuedTime": datetime.utcnow().strftime("%H:%M"),
        "issuedDate": datetime.utcnow().strftime("%d.%m.%Y"),
    }
    return jsonify(success=True, order=issued_order, message="Блюдо выдано")


@app.get("/api/cook/products")
@login_required
def api_cook_products():
    if not require_role("cook"):
        return jsonify(success=False, error="Нет доступа"), 403

    products = Product.query.order_by(Product.name.asc()).all()
    return jsonify([
        {
            "id": p.id,
            "name": p.name,
            "quantity": f"{p.quantity:.2f} {p.unit}" if p.unit != "шт" else f"{int(round(p.quantity))} {p.unit}",
            "minQuantity": f"{p.min_quantity:.2f} {p.unit}" if p.unit != "шт" else f"{int(round(p.min_quantity))} {p.unit}",
        }
        for p in products
    ])


@app.get("/api/cook/requests")
@login_required
def api_cook_requests():
    if not require_role("cook"):
        return jsonify(success=False, error="Нет доступа"), 403

    reqs = (PurchaseRequest.query
            .filter_by(created_by=current_user.id)
            .order_by(PurchaseRequest.created_at.desc())
            .limit(200)
            .all())

    out = []
    for r in reqs:
        dt = r.created_at or datetime.utcnow()
        out.append({
            "id": r.id,
            "productName": r.title,
            "quantity": str(r.amount),
            "date": dt.strftime("%d.%m.%Y"),
            "time": dt.strftime("%H:%M"),
            "status": r.status,
        })
    return jsonify(out)


@app.post("/api/cook/requests/create")
@login_required
def api_cook_requests_create():
    if not require_role("cook"):
        return jsonify(success=False, error="Нет доступа"), 403

    data = request.get_json(silent=True) or {}
    product_name = (data.get("productName") or "").strip()
    quantity = data.get("quantity")

    if not product_name:
        return jsonify(success=False, error="Нет названия продукта"), 400

    try:
        qty_int = int(float(quantity))
    except Exception:
        return jsonify(success=False, error="Некорректное количество"), 400

    pr = PurchaseRequest(
        title=product_name,
        description=None,
        amount=qty_int,
        status="pending",
        created_by=current_user.id,
    )
    db.session.add(pr)
    db.session.commit()

    dt = pr.created_at or datetime.utcnow()
    return jsonify(success=True, request={
        "id": pr.id,
        "productName": pr.title,
        "quantity": str(pr.amount),
        "date": dt.strftime("%d.%m.%Y"),
        "time": dt.strftime("%H:%M"),
        "status": pr.status,
    })

@app.route("/main_cook")
@login_required
def main_cook():
    if not require_role("cook"):
        return redirect(url_for("login"))
    return render_template("cook_dashboard.html")



@app.route("/main_admin")
@login_required
def main_admin():
    if not require_role("admin"):
        return redirect(url_for("login"))
    return render_template("main_admin.html")


def _parse_date(value: str):
    try:
        return datetime.strptime(value, "%Y-%m-%d").date()
    except Exception:
        return None


@app.get("/api/admin/stats")
@login_required
def api_admin_stats():
    if not require_role("admin"):
        return jsonify(ok=False, error="Нет доступа"), 403

    date_from = _parse_date(request.args.get("from") or "")
    date_to = _parse_date(request.args.get("to") or "")

    # по умолчанию: последние 30 дней (включая сегодня)
    if not date_to:
        date_to = datetime.utcnow().date()
    if not date_from:
        date_from = date_to - timedelta(days=29)

    if date_from > date_to:
        date_from, date_to = date_to, date_from

    dt_from = datetime.combine(date_from, datetime.min.time())
    dt_to = datetime.combine(date_to + timedelta(days=1), datetime.min.time())

    # агрегаты
    revenue = (db.session.query(db.func.coalesce(db.func.sum(Payment.amount), 0))
               .filter(Payment.direction == "in")
               .filter(Payment.created_at >= dt_from, Payment.created_at < dt_to)
               .scalar())

    expenses = (db.session.query(db.func.coalesce(db.func.sum(Expense.amount), 0))
                .filter(Expense.created_at >= dt_from, Expense.created_at < dt_to)
                .scalar())

    profit = int(revenue) - int(expenses)

    # ряды по дням
    days = []
    cur = date_from
    while cur <= date_to:
        days.append(cur)
        cur = cur + timedelta(days=1)

    rev_by_day = {d: 0 for d in days}
    exp_by_day = {d: 0 for d in days}
    att_by_day = {d: 0 for d in days}

    rev_rows = (db.session.query(db.func.date(Payment.created_at).label("day"), db.func.sum(Payment.amount))
                .filter(Payment.direction == "in")
                .filter(Payment.created_at >= dt_from, Payment.created_at < dt_to)
                .group_by(db.func.date(Payment.created_at))
                .all())
    for day, total in rev_rows:
        if day in rev_by_day:
            rev_by_day[day] = int(total or 0)

    exp_rows = (db.session.query(db.func.date(Expense.created_at).label("day"), db.func.sum(Expense.amount))
                .filter(Expense.created_at >= dt_from, Expense.created_at < dt_to)
                .group_by(db.func.date(Expense.created_at))
                .all())
    for day, total in exp_rows:
        if day in exp_by_day:
            exp_by_day[day] = int(total or 0)

    att_rows = (db.session.query(Attendance.day, db.func.count(Attendance.id))
                .filter(Attendance.day >= date_from, Attendance.day <= date_to)
                .group_by(Attendance.day)
                .all())
    for day, total in att_rows:
        if day in att_by_day:
            att_by_day[day] = int(total or 0)

    series = []
    for d in days:
        series.append({
            "day": d.isoformat(),
            "revenue": rev_by_day[d],
            "expenses": exp_by_day[d],
            "attendance": att_by_day[d],
        })

    return jsonify(ok=True, from_date=date_from.isoformat(), to_date=date_to.isoformat(), revenue=int(revenue), expenses=int(expenses), profit=profit, series=series)


@app.get("/api/admin/purchase_requests")
@login_required
def api_admin_purchase_requests():
    if not require_role("admin"):
        return jsonify(ok=False, error="Нет доступа"), 403

    status = (request.args.get("status") or "pending").strip()
    q = PurchaseRequest.query
    if status in {"pending", "approved", "rejected"}:
        q = q.filter_by(status=status)
    items = q.order_by(PurchaseRequest.created_at.desc()).limit(200).all()

    return jsonify(ok=True, items=[{
        "id": pr.id,
        "title": pr.title,
        "description": pr.description or "",
        "amount": pr.amount,
        "status": pr.status,
        "created_at": pr.created_at.isoformat() if pr.created_at else None,
        "created_by": pr.creator.username if pr.creator else None,
    } for pr in items])


@app.post("/api/admin/purchase_requests/<int:pr_id>/decision")
@login_required
def api_admin_purchase_request_decision(pr_id):
    if not require_role("admin"):
        return jsonify(ok=False, error="Нет доступа"), 403

    pr = PurchaseRequest.query.get(pr_id)
    if not pr:
        return jsonify(ok=False, error="Заявка не найдена"), 404
    if pr.status != "pending":
        return jsonify(ok=False, error="Заявка уже обработана"), 400

    data = request.get_json() or {}
    decision = (data.get("decision") or "").strip()
    if decision not in {"approved", "rejected"}:
        return jsonify(ok=False, error="Неверное решение"), 400

    pr.status = decision
    pr.decided_by = current_user.id
    pr.decided_at = datetime.utcnow()

    if decision == "approved":
        exp = Expense(purchase_request_id=pr.id, category="food", amount=pr.amount, description=pr.title)
        db.session.add(exp)
        db.session.add(Payment(
            # Some DB schemas define payments.user_id as NOT NULL.
            # Store the approving admin as the actor for this expense.
            user_id=current_user.id,
            type="expense",
            direction="out",
            kind="expense",
            amount=pr.amount,
            note=f"Закупка: {pr.title}",
        ))

    db.session.commit()
    return jsonify(ok=True)


@app.post("/api/cook/purchase_requests")
@login_required
def api_cook_create_purchase_request():
    if not require_role("cook"):
        return jsonify(ok=False, error="Нет доступа"), 403

    data = request.get_json() or {}
    title = (data.get("title") or "").strip()
    description = (data.get("description") or "").strip()
    amount = int(data.get("amount") or 0)

    if not title or amount <= 0:
        return jsonify(ok=False, error="Заполните название и сумму"), 400

    pr = PurchaseRequest(title=title, description=description, amount=amount, created_by=current_user.id)
    db.session.add(pr)
    db.session.commit()
    return jsonify(ok=True, id=pr.id)


@app.get("/api/admin/reports/nutrition.csv")
@login_required
def api_admin_report_nutrition():
    if not require_role("admin"):
        return jsonify(ok=False, error="Нет доступа"), 403

    date_from = _parse_date(request.args.get("from") or "") or (datetime.utcnow().date() - timedelta(days=29))
    date_to = _parse_date(request.args.get("to") or "") or datetime.utcnow().date()
    if date_from > date_to:
        date_from, date_to = date_to, date_from

    dt_from = datetime.combine(date_from, datetime.min.time())
    dt_to = datetime.combine(date_to + timedelta(days=1), datetime.min.time())

    rows = (db.session.query(
                db.func.date(Order.created_at).label("day"),
                db.func.count(Order.id).label("orders"),
                db.func.sum(Dish.kcal).label("kcal"),
                db.func.sum(Dish.protein).label("protein"),
                db.func.sum(Dish.fat).label("fat"),
                db.func.sum(Dish.carbs).label("carbs"),
                db.func.sum(db.case((Order.is_free == True, 1), else_=0)).label("free_orders"),
                db.func.sum(Order.price_paid).label("paid_sum"),
            )
            .join(Dish, Dish.id == Order.dish_id)
            .filter(Order.created_at >= dt_from, Order.created_at < dt_to)
            .group_by(db.func.date(Order.created_at))
            .order_by(db.func.date(Order.created_at))
            .all())

    out = io.StringIO()
    w = csv.writer(out)
    w.writerow(["date", "orders", "free_orders", "paid_sum", "kcal", "protein", "fat", "carbs"])
    for r in rows:
        w.writerow([
            r.day.isoformat(),
            int(r.orders or 0),
            int(r.free_orders or 0),
            int(r.paid_sum or 0),
            int(r.kcal or 0),
            int(r.protein or 0),
            int(r.fat or 0),
            int(r.carbs or 0),
        ])

    return Response(out.getvalue(), mimetype="text/csv", headers={"Content-Disposition": "attachment; filename=nutrition_report.csv"})


@app.get("/api/admin/reports/costs.csv")
@login_required
def api_admin_report_costs():
    if not require_role("admin"):
        return jsonify(ok=False, error="Нет доступа"), 403

    date_from = _parse_date(request.args.get("from") or "") or (datetime.utcnow().date() - timedelta(days=29))
    date_to = _parse_date(request.args.get("to") or "") or datetime.utcnow().date()
    if date_from > date_to:
        date_from, date_to = date_to, date_from

    dt_from = datetime.combine(date_from, datetime.min.time())
    dt_to = datetime.combine(date_to + timedelta(days=1), datetime.min.time())
    rev_rows = (db.session.query(db.func.date(Payment.created_at).label("day"), db.func.sum(Payment.amount).label("rev"))
                .filter(Payment.direction == "in")
                .filter(Payment.created_at >= dt_from, Payment.created_at < dt_to)
                .group_by(db.func.date(Payment.created_at))
                .all())
    exp_rows = (db.session.query(db.func.date(Expense.created_at).label("day"), db.func.sum(Expense.amount).label("exp"))
                .filter(Expense.created_at >= dt_from, Expense.created_at < dt_to)
                .group_by(db.func.date(Expense.created_at))
                .all())

    rev_map = {r.day: int(r.rev or 0) for r in rev_rows}
    exp_map = {r.day: int(r.exp or 0) for r in exp_rows}

    out = io.StringIO()
    w = csv.writer(out)
    w.writerow(["date", "revenue", "expenses", "profit"])
    cur = date_from
    while cur <= date_to:
        rev = rev_map.get(cur, 0)
        exp = exp_map.get(cur, 0)
        w.writerow([cur.isoformat(), rev, exp, rev - exp])
        cur = cur + timedelta(days=1)

    return Response(out.getvalue(), mimetype="text/csv", headers={"Content-Disposition": "attachment; filename=costs_report.csv"})

@app.post("/api/order/<int:order_id>/done")
@login_required
def api_order_done(order_id):
    if not require_role("cook"):
        return jsonify(ok=False, error="Нет доступа"), 403

    order = Order.query.get(order_id)
    if not order:
        return jsonify(ok=False, error="Заказ не найден"), 404

    if order.status != "preparing":
        return jsonify(ok=False, error="Нельзя изменить этот заказ"), 400

    order.status = "ready"
    db.session.commit()
    return jsonify(ok=True)

@app.route("/register", methods=["GET", "POST"])
def register():
    form = RegisterForm()

    if form.validate_on_submit():
        role = (request.form.get("role") or "student").strip()
        if role not in ["student", "cook", "admin"]:
            role = "student"

        hashed_password = bcrypt.generate_password_hash(form.password.data).decode("utf-8")

        new_user = User(
            username=form.username.data.strip(),
            email=form.email.data.strip(),
            password_hash=hashed_password,
            role=role,
            balance=0,
            sub_until=None
        )
        db.session.add(new_user)
        db.session.commit()

        return redirect(url_for("login"))

    return render_template("register.html", form=form)


@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("login"))

@app.route("/main_student")
@login_required
def main_student():
    if not require_role("student"):
        return redirect(url_for("login"))
    user_allergens = current_user.allergens or []
    arr = cast(user_allergens, postgresql.ARRAY(db.Text))
    dishes = Dish.query.filter(
        ~Dish.allergens.op("&&")(arr)
    ).order_by(Dish.id.asc()).all()
    for d in dishes:
        d.category_name = "Завтрак" if d.category == "breakfast" else "Обед"

    return render_template(
        "main_student.html",
        student_name=current_user.username,
        balance=current_user.balance,
        dishes=dishes,
        has_sub=has_subscription(current_user)
    )

@app.route("/profile_student")
@login_required
def profile_student():
    if not require_role("student"):
        return redirect(url_for("login"))

    return render_template(
        "profile_student.html",
        student_name=current_user.username,
        balance=current_user.balance,
        has_sub=has_subscription(current_user),
        selected_allergens=current_user.allergens or []
    )

@app.post("/api/profile/allergens")
@login_required
def api_save_allergens():
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа")

    data = request.get_json() or {}
    allergens = data.get("allergens") or []

    allowed = {"nuts", "lactose", "gluten", "fish", "eggs"}
    allergens = [a for a in allergens if a in allowed]

    current_user.allergens = allergens
    db.session.commit()

    return jsonify(ok=True, allergens=allergens)

# ---- API (виртуальные операции) ----

@app.post("/api/topup")
@login_required
def api_topup():
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа")

    data = request.get_json() or {}
    amount = int(data.get("amount") or 0)

    if amount <= 0:
        return jsonify(ok=False, error="Введите сумму")

    current_user.balance += amount
    db.session.add(Payment(
        user_id=current_user.id,
        type="topup",
        direction="in",
        kind="topup",
        amount=amount,
        note="Пополнение баланса",
    ))
    db.session.commit()
    return jsonify(ok=True, balance=current_user.balance)


@app.post("/api/subscribe")
@login_required
def api_subscribe():
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа")

    PRICE = 5000

    if has_subscription(current_user):
        return jsonify(ok=False, error="Абонемент уже активен")

    if current_user.balance < PRICE:
        return jsonify(ok=False, error="Недостаточно средств")

    current_user.balance -= PRICE
    current_user.sub_until = datetime.utcnow() + timedelta(days=30)
    db.session.add(Payment(
        user_id=current_user.id,
        type="subscription",
        direction="in",
        kind="subscription",
        amount=PRICE,
        note="Покупка абонемента",
    ))
    db.session.commit()

    return jsonify(ok=True, balance=current_user.balance)


@app.get("/api/dish/<int:dish_id>")
@login_required
def api_dish(dish_id):
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа")

    dish = Dish.query.get(dish_id)
    if not dish:
        return jsonify(ok=False, error="Блюдо не найдено")

    return jsonify(
        ok=True,
        free=has_subscription(current_user),
        id=dish.id,
        name=dish.name,
        description=dish.description,
        image_url=dish.image_url,
        kcal=dish.kcal,
        protein=dish.protein,
        fat=dish.fat,
        carbs=dish.carbs,
        price=dish.price
    )


@app.post("/api/buy/<int:dish_id>")
@login_required
def api_buy(dish_id):
    if not require_role("student"):
        return jsonify(ok=False, error="Нет доступа"), 403

    dish = Dish.query.get(dish_id)
    if not dish:
        return jsonify(ok=False, error="Блюдо не найдено"), 404

    free = has_subscription(current_user)
    paid = 0

    if not free:
        if current_user.balance < dish.price:
            return jsonify(ok=False, error="Недостаточно средств"), 400
        current_user.balance -= dish.price
        paid = dish.price

        db.session.add(Payment(
            user_id=current_user.id,
            type="order",
            direction="in",
            kind="order",
            amount=paid,
            note=f"Покупка: {dish.name}",
        ))

    order = Order(
        user_id=current_user.id,
        dish_id=dish.id,
        status="preparing",
        is_free=free,
        price_paid=paid
    )
    db.session.add(order)
    db.session.commit()

    return jsonify(ok=True, free=free, balance=current_user.balance, order_id=order.id)


if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000, debug=True)

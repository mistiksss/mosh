
const API_URL = '/api/cook';


document.addEventListener('DOMContentLoaded', function() {
    initApp();
    setupEventListeners();
    loadOrders();
});

function initApp() {
    const today = new Date();
    const formattedDate = today.toLocaleDateString('ru-RU', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
    document.getElementById('currentDate').textContent = `Сегодня: ${formattedDate}`;
}

function setupEventListeners() {
    document.querySelectorAll('.tab').forEach(tab => {
        tab.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });

    document.getElementById('logoutBtn').addEventListener('click', function() {
        if (confirm('Вы действительно хотите выйти?')) {
            window.location.href = '/logout';
        }
    });

    document.getElementById('newRequestBtn').addEventListener('click', function() {
        const form = document.getElementById('requestForm');
        form.classList.toggle('active');
    });

    document.getElementById('submitRequestBtn').addEventListener('click', submitRequest);
}

function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    document.querySelectorAll('.content-section').forEach(s => s.classList.remove('active'));
    document.getElementById(tabName).classList.add('active');

    switch(tabName) {
        case 'issuance':
            loadOrders();
            break;
        case 'warehouse':
            loadProducts();
            break;
        case 'requests':
            loadRequests();
            break;
    }
}

async function loadOrders() {
    try {
        const response = await fetch(`${API_URL}/orders`);
        const data = await response.json();

        displayOrders(data.pending);
        displayIssuedToday(data.issued);
    } catch (error) {
        console.error('Ошибка загрузки заказов:', error);
    }
}

function displayOrders(orders) {
    const ordersList = document.getElementById('ordersList');
    const noOrdersMessage = document.getElementById('noOrdersMessage');

    ordersList.innerHTML = '';

    if (orders.length === 0) {
        noOrdersMessage.style.display = 'block';
        return;
    }

    noOrdersMessage.style.display = 'none';

    orders.forEach(order => {
        const orderDiv = document.createElement('div');
        orderDiv.className = 'order-item';
        orderDiv.dataset.orderId = order.id;
        orderDiv.innerHTML = `
            <div class="order-title">${order.name}</div>
            <div class="order-id">Заказ #${order.id}</div>
            <button class="issue-btn" onclick="issueOrder('${order.id}')">Выдать блюдо</button>
        `;
        ordersList.appendChild(orderDiv);
    });
}

function displayIssuedToday(issuedOrders) {
    const issuedTodayList = document.getElementById('issuedTodayList');

    if (!issuedTodayList) return;

    issuedTodayList.innerHTML = '';

    const today = new Date().toLocaleDateString('ru-RU');
    const todayIssued = issuedOrders.filter(order => order.issuedDate === today);

    if (todayIssued.length === 0) {
        issuedTodayList.innerHTML = '<p>Сегодня еще ничего не выдано</p>';
        return;
    }

    todayIssued.forEach(order => {
        const item = document.createElement('div');
        item.className = 'request-item';
        item.innerHTML = `
            <div class="request-info">
                <span class="request-product">${order.name}</span>
                <span class="request-quantity">${order.issuedTime}</span>
            </div>
            <div class="request-status">Заказ #${order.id}</div>
        `;
        issuedTodayList.appendChild(item);
    });
}

async function issueOrder(orderId) {
    try {
        const response = await fetch(`${API_URL}/orders/issue`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ orderId })
        });

        let data = null;
        try {
            data = await response.json();
        } catch (e) {
            data = null;
        }

        if (!response.ok) {
            const msg = (data && (data.error || data.message)) || `Ошибка: ${response.status}`;
            alert(msg);
            return;
        }

        if (!data || data.success !== true) {
            const msg = (data && (data.error || data.message)) || 'Не удалось выдать блюдо';
            alert(msg);
            return;
        }

        alert(data.message || `Блюдо "${(data.order && data.order.name) ? data.order.name : ''}" выдано`);

        
        loadOrders();

        
        if (document.getElementById('warehouse').classList.contains('active')) {
            loadProducts();
        }
    } catch (error) {
        console.error('Ошибка выдачи заказа:', error);
        alert('Ошибка при выдаче блюда');
    }
}

async function loadProducts() {
    try {
        const response = await fetch(`${API_URL}/products`);
        const products = await response.json();

        displayProducts(products);
    } catch (error) {
        console.error('Ошибка загрузки продуктов:', error);
    }
}

function displayProducts(products) {
    const productsTable = document.getElementById('productsTable');
    productsTable.innerHTML = '';

    products.forEach(product => {
        const row = document.createElement('tr');

        const quantityParts = product.quantity.split(' ');
        const quantityNum = parseFloat(quantityParts[0]);
        const unit = quantityParts.length > 1 ? quantityParts[1] : '';
        const minQuantity = product.minQuantity ? parseFloat(product.minQuantity.split(' ')[0]) : 0;

        let quantityClass = '';
        if (quantityNum <= minQuantity) {
            quantityClass = 'low-stock';
        } else if (quantityNum <= minQuantity * 1.5) {
            quantityClass = 'warning-stock';
        }

        const formattedQuantity = unit === 'шт'
            ? `${Math.round(quantityNum)} ${unit}`
            : `${quantityNum.toFixed(2)} ${unit}`;

        row.innerHTML = `
            <td>${product.name}</td>
            <td class="${quantityClass}">${formattedQuantity}</td>
            <td>
                <button class="order-product-btn" onclick="createRequest('${product.name}')">
                    Заказать
                </button>
            </td>
        `;
        productsTable.appendChild(row);
    });
}

function createRequest(productName) {
    switchTab('requests');

    const form = document.getElementById('requestForm');
    form.classList.add('active');

    document.getElementById('productName').value = productName;
    document.getElementById('productQuantity').value = 100;
    document.getElementById('productName').focus();
}

async function loadRequests() {
    try {
        const response = await fetch(`${API_URL}/requests`);
        const requests = await response.json();

        displayRequests(requests);
    } catch (error) {
        console.error('Ошибка загрузки заявок:', error);
    }
}

function displayRequests(requests) {
    const requestsList = document.getElementById('requestsList');

    requestsList.innerHTML = '';

    if (requests.length === 0) {
        requestsList.innerHTML = '<p>Нет активных заявок</p>';
        return;
    }

    requests.forEach(request => {
        const item = document.createElement('div');
        item.className = 'request-item';
        item.innerHTML = `
            <div class="request-info">
                <span class="request-product">${request.productName}</span>
                <span class="request-quantity">${request.quantity}</span>
            </div>
            <div class="request-info">
                <span class="request-status">${request.date} ${request.time}</span>
                <span class="request-status">${request.status}</span>
            </div>
        `;
        requestsList.appendChild(item);
    });
}

async function submitRequest() {
    const productName = document.getElementById('productName').value.trim();
    const quantity = document.getElementById('productQuantity').value.trim();
    const unit = document.getElementById('productUnit').value;

    if (!productName || !quantity) {
        alert('Заполните все поля');
        return;
    }

    try {
        const response = await fetch(`${API_URL}/requests/create`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ productName, quantity, unit })
        });

        const data = await response.json();

        if (data.success) {
            alert(`Заявка на "${productName}" отправлена`);

            document.getElementById('productName').value = '';
            document.getElementById('productQuantity').value = '';
            if(document.getElementById('productUnit')) document.getElementById('productUnit').value = 'шт';
            document.getElementById('requestForm').classList.remove('active');

            loadRequests();
        }
    } catch (error) {
        console.error('Ошибка отправки заявки:', error);
        alert('Ошибка при отправке заявки');
    }
}

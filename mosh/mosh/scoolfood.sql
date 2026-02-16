--
-- PostgreSQL database dump
--

\restrict Pcoln0brLAC1ut0bOM61Em256wMrSghbIibRihYupuvTh50IKvexO651y8Trejs

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_reports (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    text text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_reports OWNER TO postgres;

--
-- Name: admin_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_reports_id_seq OWNER TO postgres;

--
-- Name: admin_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_reports_id_seq OWNED BY public.admin_reports.id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    user_id integer NOT NULL,
    day date NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: dish_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish_ingredients (
    id integer NOT NULL,
    dish_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    unit character varying(20) NOT NULL
);


ALTER TABLE public.dish_ingredients OWNER TO postgres;

--
-- Name: dish_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dish_ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dish_ingredients_id_seq OWNER TO postgres;

--
-- Name: dish_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dish_ingredients_id_seq OWNED BY public.dish_ingredients.id;


--
-- Name: dishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishes (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    short_desc character varying(256) NOT NULL,
    description text NOT NULL,
    category character varying(20) NOT NULL,
    price integer NOT NULL,
    image_url text NOT NULL,
    kcal integer NOT NULL,
    protein integer NOT NULL,
    fat integer NOT NULL,
    carbs integer NOT NULL,
    allergens text[] DEFAULT ARRAY[]::text[] NOT NULL
);


ALTER TABLE public.dishes OWNER TO postgres;

--
-- Name: dishes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dishes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishes_id_seq OWNER TO postgres;

--
-- Name: dishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dishes_id_seq OWNED BY public.dishes.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    purchase_request_id integer,
    category character varying(50) DEFAULT 'food'::character varying NOT NULL,
    amount integer NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.expenses OWNER TO postgres;

--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expenses_id_seq OWNER TO postgres;

--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_items (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    unit character varying(20) DEFAULT 'шт'::character varying NOT NULL,
    qty double precision DEFAULT 0 NOT NULL,
    min_qty double precision DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.inventory_items OWNER TO postgres;

--
-- Name: inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_items_id_seq OWNER TO postgres;

--
-- Name: inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_items_id_seq OWNED BY public.inventory_items.id;


--
-- Name: meal_pickups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_pickups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    order_id integer,
    day date DEFAULT CURRENT_DATE NOT NULL,
    meal_type character varying(20) DEFAULT 'lunch'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.meal_pickups OWNER TO postgres;

--
-- Name: meal_pickups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meal_pickups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meal_pickups_id_seq OWNER TO postgres;

--
-- Name: meal_pickups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meal_pickups_id_seq OWNED BY public.meal_pickups.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message character varying(300) NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    dish_id integer NOT NULL,
    status character varying(20) DEFAULT 'preparing'::character varying NOT NULL,
    is_free boolean DEFAULT false NOT NULL,
    price_paid integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    type character varying(30) NOT NULL,
    amount integer NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    direction character varying(8) DEFAULT 'in'::character varying NOT NULL,
    kind character varying(32) DEFAULT 'topup'::character varying NOT NULL,
    note character varying(256)
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: procurement_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.procurement_requests (
    id integer NOT NULL,
    cook_id integer NOT NULL,
    status character varying(20) DEFAULT 'new'::character varying NOT NULL,
    items jsonb DEFAULT '[]'::jsonb NOT NULL,
    comment character varying(300) DEFAULT ''::character varying NOT NULL,
    admin_comment character varying(300) DEFAULT ''::character varying NOT NULL,
    decided_by integer,
    decided_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.procurement_requests OWNER TO postgres;

--
-- Name: procurement_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.procurement_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.procurement_requests_id_seq OWNER TO postgres;

--
-- Name: procurement_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.procurement_requests_id_seq OWNED BY public.procurement_requests.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    quantity double precision DEFAULT 0 NOT NULL,
    unit character varying(20) DEFAULT 'шт'::character varying NOT NULL,
    min_quantity double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: purchase_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_requests (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    amount integer NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_by integer NOT NULL,
    decided_by integer,
    created_at timestamp without time zone DEFAULT now(),
    decided_at timestamp without time zone
);


ALTER TABLE public.purchase_requests OWNER TO postgres;

--
-- Name: purchase_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_requests_id_seq OWNER TO postgres;

--
-- Name: purchase_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_requests_id_seq OWNED BY public.purchase_requests.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    user_id integer NOT NULL,
    dish_id integer NOT NULL,
    rating integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq OWNER TO postgres;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(20) NOT NULL,
    email character varying(70) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(20) DEFAULT 'student'::character varying NOT NULL,
    balance integer DEFAULT 0 NOT NULL,
    sub_until timestamp without time zone,
    allergens text[] DEFAULT ARRAY[]::text[] NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admin_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_reports ALTER COLUMN id SET DEFAULT nextval('public.admin_reports_id_seq'::regclass);


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: dish_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_ingredients ALTER COLUMN id SET DEFAULT nextval('public.dish_ingredients_id_seq'::regclass);


--
-- Name: dishes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes ALTER COLUMN id SET DEFAULT nextval('public.dishes_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: inventory_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_items ALTER COLUMN id SET DEFAULT nextval('public.inventory_items_id_seq'::regclass);


--
-- Name: meal_pickups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_pickups ALTER COLUMN id SET DEFAULT nextval('public.meal_pickups_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: procurement_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procurement_requests ALTER COLUMN id SET DEFAULT nextval('public.procurement_requests_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: purchase_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_requests ALTER COLUMN id SET DEFAULT nextval('public.purchase_requests_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: admin_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_reports (id, admin_id, text, created_at) FROM stdin;
1	6	Jxty	2026-02-09 18:52:08.546065
2	11	Все круто в этом месяце, прибыль большая!	2026-02-16 16:34:50.791908
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, user_id, day, created_at) FROM stdin;
1	3	2026-02-08	2026-02-08 13:41:22.825098
2	3	2026-02-09	2026-02-09 12:30:23.326091
3	9	2026-02-09	2026-02-09 22:15:30.102791
4	9	2026-02-12	2026-02-12 09:30:57.203576
5	9	2026-02-15	2026-02-15 17:40:09.658282
6	9	2026-02-16	2026-02-16 12:25:49.753224
7	15	2026-02-16	2026-02-16 15:58:57.590392
\.


--
-- Data for Name: dish_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dish_ingredients (id, dish_id, product_id, quantity, unit) FROM stdin;
1	1	1	1	л
\.


--
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dishes (id, name, short_desc, description, category, price, image_url, kcal, protein, fat, carbs, allergens) FROM stdin;
1	Овсянка с бананом	Овсянка на молоке с бананом	Овсяная каша на молоке с бананом и медом.	breakfast	120	https://i.postimg.cc/SRxvhf7y/image.png	320	10	8	52	{}
2	Омлет с сыром	Омлет из 2 яиц с сыром	Нежный омлет из яиц с сыром, подается теплым.	breakfast	150	https://i.postimg.cc/LsVD8Zsr/image.png	280	16	20	4	{eggs,milk}
3	Куриный суп	Куриный суп с овощами	Легкий куриный суп с овощами и зеленью.	lunch	170	https://i.postimg.cc/0yYdVJ7g/image.png	250	18	8	20	{}
4	Гречка с котлетой	Гречка и говяжья котлета	Гречка с домашней котлетой из говядины и подливой.	lunch	220	https://i.postimg.cc/pyNzZ2Tf/image.png	520	28	22	55	{gluten}
5	Паста Болоньезе	Паста с мясным соусом	Паста с классическим соусом болоньезе (говядина/томат).	lunch	240	https://i.postimg.cc/9fxxB7jZ/image.png	610	30	18	78	{gluten}
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expenses (id, purchase_request_id, category, amount, description, created_at) FROM stdin;
1	2	food	100	Молоко	2026-02-08 14:01:18.837327
2	\N	food	663	Закупка по заявке #8	2026-02-09 18:51:15.874685
3	\N	food	787	Закупка по заявке #9	2026-02-09 22:18:34.036313
4	\N	food	626	Закупка по заявке #10	2026-02-16 12:40:36.823936
5	\N	food	930	Закупка по заявке #11	2026-02-16 16:01:42.806538
\.


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_items (id, name, unit, qty, min_qty, updated_at) FROM stdin;
\.


--
-- Data for Name: meal_pickups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meal_pickups (id, user_id, order_id, day, meal_type, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, message, is_read, created_at) FROM stdin;
2	2	Новый заказ #8: Овсянка с бананом (ученик: admin)	f	2026-02-09 19:45:01.269338
3	4	Новый заказ #8: Овсянка с бананом (ученик: admin)	f	2026-02-09 19:45:01.269338
4	5	Новый заказ #8: Овсянка с бананом (ученик: admin)	f	2026-02-09 19:45:01.269338
6	2	Новый заказ #9: Омлет с сыром (ученик: admin)	f	2026-02-09 19:46:24.649376
7	4	Новый заказ #9: Омлет с сыром (ученик: admin)	f	2026-02-09 19:46:24.649376
8	5	Новый заказ #9: Омлет с сыром (ученик: admin)	f	2026-02-09 19:46:24.649376
9	3	Ваш заказ #8 готов: Овсянка с бананом	f	2026-02-09 19:46:44.403593
10	3	Ваш заказ #9 готов: Омлет с сыром	f	2026-02-09 19:46:47.071494
1	8	Новый заказ #8: Овсянка с бананом (ученик: admin)	t	2026-02-09 19:45:01.269338
5	8	Новый заказ #9: Омлет с сыром (ученик: admin)	t	2026-02-09 19:46:24.649376
11	2	Новый заказ #22: Куриный суп	f	2026-02-16 12:25:33.784918
13	4	Новый заказ #22: Куриный суп	f	2026-02-16 12:25:33.784918
14	5	Новый заказ #22: Куриный суп	f	2026-02-16 12:25:33.784918
15	8	Новый заказ #22: Куриный суп	f	2026-02-16 12:25:33.784918
12	10	Новый заказ #22: Куриный суп	t	2026-02-16 12:25:33.784918
39	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:33.346555
38	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:32.962085
37	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:32.42924
36	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:26.237412
35	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:25.654689
34	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:18.124362
33	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:17.908942
32	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:17.693411
31	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:17.257577
30	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:11.029392
29	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:09.710509
28	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:09.317092
27	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:08.541874
26	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:08.349338
25	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:07.724323
24	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:07.533671
23	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:07.336229
22	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:06.109944
21	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:26:04.834819
20	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:25:58.47936
19	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:25:54.648867
18	9	Ваш заказ #22 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:25:52.920582
17	9	Ваш заказ #21 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:25:49.753224
16	9	Заказ #22 создан. Статус: готовится.	t	2026-02-16 12:25:33.784918
40	2	Новый заказ #23: Омлет с сыром	f	2026-02-16 12:39:31.581647
42	4	Новый заказ #23: Омлет с сыром	f	2026-02-16 12:39:31.581647
43	5	Новый заказ #23: Омлет с сыром	f	2026-02-16 12:39:31.581647
44	8	Новый заказ #23: Омлет с сыром	f	2026-02-16 12:39:31.581647
45	9	Заказ #23 создан. Статус: готовится.	t	2026-02-16 12:39:31.581647
41	10	Новый заказ #23: Омлет с сыром	t	2026-02-16 12:39:31.581647
47	6	Новая заявка на закупку #10: омоо — 100.0 шт	f	2026-02-16 12:40:24.200696
48	11	Новая заявка на закупку #10: омоо — 100.0 шт	t	2026-02-16 12:40:24.200696
49	10	Ваша заявка на закупку #10: решение администратора — approved.	t	2026-02-16 12:40:36.823936
46	9	Ваш заказ #23 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 12:40:12.125468
50	2	Новый заказ #24: Овсянка с бананом	f	2026-02-16 15:56:36.024967
52	4	Новый заказ #24: Овсянка с бананом	f	2026-02-16 15:56:36.024967
53	5	Новый заказ #24: Овсянка с бананом	f	2026-02-16 15:56:36.024967
54	8	Новый заказ #24: Овсянка с бананом	f	2026-02-16 15:56:36.024967
56	2	Новый заказ #25: Омлет с сыром	f	2026-02-16 15:56:51.045182
58	4	Новый заказ #25: Омлет с сыром	f	2026-02-16 15:56:51.045182
59	5	Новый заказ #25: Омлет с сыром	f	2026-02-16 15:56:51.045182
60	8	Новый заказ #25: Омлет с сыром	f	2026-02-16 15:56:51.045182
51	10	Новый заказ #24: Овсянка с бананом	t	2026-02-16 15:56:36.024967
57	10	Новый заказ #25: Омлет с сыром	t	2026-02-16 15:56:51.045182
55	15	Заказ #24 создан. Статус: готовится.	t	2026-02-16 15:56:36.024967
61	15	Заказ #25 создан. Статус: готовится.	t	2026-02-16 15:56:51.045182
62	15	Ваш заказ #24 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 15:58:57.590392
63	15	Ваш заказ #25 выдан. Нажмите «Получено» в списке заказов.	t	2026-02-16 15:58:59.922652
64	2	Студент test222 подтвердил получение заказа #25	f	2026-02-16 15:59:24.230865
65	10	Студент test222 подтвердил получение заказа #25	f	2026-02-16 15:59:24.230865
66	4	Студент test222 подтвердил получение заказа #25	f	2026-02-16 15:59:24.230865
67	5	Студент test222 подтвердил получение заказа #25	f	2026-02-16 15:59:24.230865
68	8	Студент test222 подтвердил получение заказа #25	f	2026-02-16 15:59:24.230865
69	2	Студент test222 подтвердил получение заказа #24	f	2026-02-16 15:59:25.791671
70	10	Студент test222 подтвердил получение заказа #24	f	2026-02-16 15:59:25.791671
71	4	Студент test222 подтвердил получение заказа #24	f	2026-02-16 15:59:25.791671
72	5	Студент test222 подтвердил получение заказа #24	f	2026-02-16 15:59:25.791671
73	8	Студент test222 подтвердил получение заказа #24	f	2026-02-16 15:59:25.791671
74	6	Новая заявка на закупку #11: Яйца — 150.0 л	f	2026-02-16 16:01:23.604376
75	11	Новая заявка на закупку #11: Яйца — 150.0 л	f	2026-02-16 16:01:23.604376
76	10	Ваша заявка на закупку #11: решение администратора — approved.	f	2026-02-16 16:01:42.806538
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, user_id, dish_id, status, is_free, price_paid, created_at) FROM stdin;
1	3	1	picked	f	120	2026-02-06 10:06:47.920655
2	3	1	picked	f	120	2026-02-08 13:39:49.801575
3	3	1	picked	t	0	2026-02-09 11:37:45.013185
4	3	1	picked	t	0	2026-02-09 12:10:17.272924
5	3	2	picked	t	0	2026-02-09 12:29:53.501652
6	3	2	picked	t	0	2026-02-09 13:02:31.788306
7	3	1	picked	t	0	2026-02-09 13:02:38.928234
8	3	1	picked	t	0	2026-02-09 19:45:01.269338
9	3	2	picked	t	0	2026-02-09 19:46:24.649376
10	9	1	picked	f	120	2026-02-09 22:12:51.996138
11	9	2	picked	f	150	2026-02-09 22:12:55.657387
12	9	1	picked	t	0	2026-02-09 22:13:08.319074
13	9	1	picked	t	0	2026-02-12 09:30:48.990807
14	9	2	picked	t	0	2026-02-12 09:43:23.215092
15	9	1	picked	t	0	2026-02-15 17:13:34.894008
19	9	1	picked	t	0	2026-02-15 17:39:53.017389
18	9	2	picked	t	0	2026-02-15 17:13:42.842353
17	9	1	picked	t	0	2026-02-15 17:13:37.270829
16	9	1	picked	t	0	2026-02-15 17:13:36.117256
20	9	5	picked	t	0	2026-02-15 17:40:32.142859
21	9	1	issued	t	0	2026-02-15 18:27:07.647478
22	9	3	issued	t	0	2026-02-16 12:25:33.774785
23	9	2	issued	t	0	2026-02-16 12:39:31.575812
25	15	2	picked	t	0	2026-02-16 15:56:51.028804
24	15	1	picked	f	120	2026-02-16 15:56:35.974491
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, user_id, type, amount, meta, created_at, direction, kind, note) FROM stdin;
14	3	topup	1000	{}	2026-02-06 10:06:31.813356	in	topup	Пополнение баланса
15	3	topup	10000	{}	2026-02-06 10:06:46.110222	in	topup	Пополнение баланса
16	3	order	120	{}	2026-02-06 10:06:47.920655	in	order	Покупка: Овсянка с бананом
17	3	order	120	{}	2026-02-08 13:39:49.801575	in	order	Покупка: Овсянка с бананом
25	3	subscription	5000	{}	2026-02-08 13:59:33.400337	in	subscription	Покупка абонемента
26	6	expense	100	{}	2026-02-08 14:01:18.837327	out	expense	Закупка: Молоко
27	6	expense	663	{}	2026-02-09 18:51:15.874685	out	expense	Закупка по заявке #8
28	9	topup	10000	{}	2026-02-09 22:12:38.727776	in	topup	Пополнение баланса
29	9	order	120	{}	2026-02-09 22:12:51.996138	in	order	Покупка: Овсянка с бананом
30	9	order	150	{}	2026-02-09 22:12:55.657387	in	order	Покупка: Омлет с сыром
31	9	subscription	5000	{}	2026-02-09 22:13:04.719369	in	subscription	Покупка абонемента
32	11	expense	787	{}	2026-02-09 22:18:34.036313	out	expense	Закупка по заявке #9
33	9	topup	5000	{"method": "card", "card_hash": "d707dc92f34aee753abede9e065f7072dfda9bae95eccd09bf13d0261a14335a"}	2026-02-12 09:04:30.265978	in	topup	Пополнение баланса (карта)
34	11	expense	626	{}	2026-02-16 12:40:36.823936	out	expense	Закупка по заявке #10
35	15	topup	10000	{"method": "card", "card_hash": "4d00b39ba40481be17f492e3abf846469880e206fc23e900bca6548fc71dd88b"}	2026-02-16 15:56:32.298093	in	topup	Пополнение баланса (карта)
36	15	order	120	{}	2026-02-16 15:56:35.974491	in	order	Покупка: Овсянка с бананом
37	15	subscription	5000	{}	2026-02-16 15:56:46.338034	in	subscription	Покупка абонемента
38	11	expense	930	{}	2026-02-16 16:01:42.806538	out	expense	Закупка по заявке #11
\.


--
-- Data for Name: procurement_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.procurement_requests (id, cook_id, status, items, comment, admin_comment, decided_by, decided_at, created_at) FROM stdin;
2	4	rejected	[{"qty": 1.0, "name": "apple", "unit": "шт", "price": 12.0}]	pls		6	2026-02-09 10:36:16.014066	2026-02-05 09:18:39.28472
1	2	rejected	[{"qty": 3.0, "name": "[eq", "unit": "шт", "price": 10.0}]			6	2026-02-09 10:36:16.476502	2026-01-20 12:09:37.356928
7	8	approved	[{"qty": 100.0, "name": "hhhhh", "unit": "л"}]			6	2026-02-09 11:03:40.594554	2026-02-09 13:42:19.014349
6	8	approved	[{"qty": 100.0, "name": "Картофель", "unit": "шт"}]			6	2026-02-09 11:03:41.287346	2026-02-09 13:41:43.602826
5	8	rejected	[{"qty": 100.0, "name": "Картофель", "unit": "шт"}]			6	2026-02-09 11:03:42.015406	2026-02-09 13:35:23.048577
4	8	rejected	[{"qty": 100.0, "name": "Молоко", "unit": "шт"}]			6	2026-02-09 11:03:42.763135	2026-02-09 13:05:42.710658
3	8	approved	[{"qty": 100.0, "name": "Картофель", "unit": "кг"}]			6	2026-02-09 11:03:43.418342	2026-02-09 13:03:24.696342
8	8	approved	[{"qty": 100.0, "name": "Молоко", "unit": "л"}]			6	2026-02-09 15:51:15.879016	2026-02-09 18:50:50.537304
9	10	approved	[{"qty": 10.0, "name": "Молоко", "unit": "л"}]			11	2026-02-09 19:18:34.045369	2026-02-09 22:18:17.39874
10	10	approved	[{"qty": 100.0, "name": "омоо", "unit": "шт"}]			11	2026-02-16 09:40:36.826933	2026-02-16 12:40:24.193419
11	10	approved	[{"qty": 150.0, "name": "Яйца", "unit": "л"}]			11	2026-02-16 13:01:42.81175	2026-02-16 16:01:23.569044
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, quantity, unit, min_quantity) FROM stdin;
5	hhhhh	100	л	0
2	Картофель	250	кг	10
6	омоо	100	шт	0
1	Молоко	107	л	5
3	Яйца	250	шт	30
\.


--
-- Data for Name: purchase_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_requests (id, title, description, amount, status, created_by, decided_by, created_at, decided_at) FROM stdin;
1	Картофель	\N	100	rejected	8	6	2026-02-08 13:41:43.478284	2026-02-08 10:42:24.384826
2	Молоко	\N	100	approved	8	6	2026-02-08 14:00:40.225211	2026-02-08 11:01:18.840276
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, user_id, dish_id, rating, text, created_at) FROM stdin;
1	3	1	5	топчик вкусно	2026-02-09 12:29:07.49516
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, role, balance, sub_until, allergens, created_at) FROM stdin;
1	fhfdddd	u@mail.ru	$2b$12$hRJLzuq2xItVsxOqQRchDO42sJFsWsR4e2VmlNdheOslb9K8TX1gy	student	0	\N	{}	2026-01-20 12:07:40.094544
2	p@mail.ru	p@mail.ru	$2b$12$lk1EWNT3.A/19GUpDMptyeTKN8rJ6yz3Na2vixHtoePCxcizhTmO6	cook	0	\N	{}	2026-01-20 12:09:07.691361
10	cook	cook@mail.ru	$2b$12$247v4ORYjNyA539N6UsdM..oeF6D4HjQ0wBgOxOc/n04TVogwe3Ma	cook	0	\N	{}	2026-02-09 21:45:10.646528
4	e.kraeva@bda.com	e.kraeva@bda.com	$2b$12$Joj2fbeZXj0hf20qFoo2p.aCEj2ashKOmKBnmUMIyUjyypN6Raqda	cook	0	\N	{}	2026-02-05 09:18:09.156661
5	k@mail.ru	k@mail.ru	$2b$12$fQrwsit.Lj7JRXFqOO6tW.8cwtCub5Z2SL5nqHZoiUHVM/Il9DxNe	cook	0	\N	{}	2026-02-06 08:32:03.934855
6	admi	a@mail.ru	$2b$12$kPJLL9kKzTd4fP3OmCYIjO9/IN3rmC5QwAwV5umDUXpK.QPwGQGyW	admin	0	\N	{}	2026-02-06 08:55:16.998152
11	admin1	admin@mail.ru	$2b$12$FV4/bioajLUtAumCBi22N.KPfnbaI723i6sGHfV9agSrM3PiGJI9e	admin	0	\N	{}	2026-02-09 21:45:55.406342
12	testuser	testus@mail.ru	$2b$12$fAhwC5r3LdJY9t6js8OOM.WmYhtmWRQ4FDg3QutuY04TsBHdM.GSW	student	0	\N	{}	2026-02-09 21:58:51.491675
13	test	test@mail.ru	$2b$12$ogVLvHZuADa/gqWp.vq.xeRqiY1pHwL/Ca1OIhY65oAePW5XSjAO.	student	0	\N	{}	2026-02-09 22:00:02.875218
14	test1	test1@mail.ru	$2b$12$O9EtpKrXqErVe3FWodjTA.e5wBhr1yHLbPZjoCm5r6RCU/c3NLVGm	student	0	\N	{}	2026-02-09 22:05:02.791991
9	student	student@mail.ru	$2b$12$m9D6dTKwh5DpYMui9CNdgOvkXqZp7kuXd7KlK3d5tAHzKM.qb48yS	student	9730	2026-03-11 19:13:04.721109	{nuts,lactose,gluten}	2026-02-09 21:44:22.119853
15	test222	d@mail.ru	$2b$12$CxTgPrCyYAfU6C5vAnVE5.DoEXBeUfGOmQrfDx57W/T.Gox4sx6mC	student	4880	2026-03-18 12:56:46.340964	{}	2026-02-16 15:54:28.03943
7	повар	o@mail.ru	$2b$12$F7R9d8HC9LxQUXpKw3vk6O3qoXIdgJaZHfB13.7cmUnNUmIS42FiW	student	0	\N	{}	2026-02-08 13:40:25.42824
8	i@mail.ru	i@mail.ru	$2b$12$Q1L4FtgCGnIFMiBJS2DC1.trKR4DtF6NMK1TvGOiiGIGw1d8bPBkW	cook	0	\N	{}	2026-02-08 13:41:08.559498
3	admin	guzarevicvlad47@mail.ru	$2b$12$DmZOp2VxQthogHFW.fViMOQ8oUG0f0yYIf1KGPN6sfk5EG66MYeA.	student	5760	2026-03-10 10:59:33.401792	{}	2026-02-05 09:17:18.227419
\.


--
-- Name: admin_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_reports_id_seq', 2, true);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 7, true);


--
-- Name: dish_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dish_ingredients_id_seq', 1, true);


--
-- Name: dishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dishes_id_seq', 5, true);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expenses_id_seq', 5, true);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_items_id_seq', 1, false);


--
-- Name: meal_pickups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meal_pickups_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 76, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 25, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 38, true);


--
-- Name: procurement_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.procurement_requests_id_seq', 11, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 6, true);


--
-- Name: purchase_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_requests_id_seq', 2, true);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: admin_reports admin_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_reports
    ADD CONSTRAINT admin_reports_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: dish_ingredients dish_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_ingredients
    ADD CONSTRAINT dish_ingredients_pkey PRIMARY KEY (id);


--
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: inventory_items inventory_items_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_name_key UNIQUE (name);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: meal_pickups meal_pickups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_pickups
    ADD CONSTRAINT meal_pickups_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: procurement_requests procurement_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procurement_requests
    ADD CONSTRAINT procurement_requests_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: purchase_requests purchase_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_requests
    ADD CONSTRAINT purchase_requests_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: attendance uq_attendance_user_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT uq_attendance_user_day UNIQUE (user_id, day);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- Name: idx_orders_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user ON public.orders USING btree (user_id);


--
-- Name: idx_payments_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_type ON public.payments USING btree (type);


--
-- Name: idx_payments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_user ON public.payments USING btree (user_id);


--
-- Name: idx_pickups_user_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pickups_user_day ON public.meal_pickups USING btree (user_id, day);


--
-- Name: idx_proc_cook; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_proc_cook ON public.procurement_requests USING btree (cook_id);


--
-- Name: idx_proc_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_proc_status ON public.procurement_requests USING btree (status);


--
-- Name: idx_reviews_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_dish ON public.reviews USING btree (dish_id);


--
-- Name: ix_admin_reports_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_admin_reports_created_at ON public.admin_reports USING btree (created_at DESC);


--
-- Name: ix_dish_ingredients_dish; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dish_ingredients_dish ON public.dish_ingredients USING btree (dish_id);


--
-- Name: ix_notifications_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_user_created ON public.notifications USING btree (user_id, created_at DESC);


--
-- Name: uq_dish_ingredients_dish_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_dish_ingredients_dish_product ON public.dish_ingredients USING btree (dish_id, product_id);


--
-- Name: admin_reports admin_reports_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_reports
    ADD CONSTRAINT admin_reports_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: attendance attendance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: dish_ingredients dish_ingredients_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_ingredients
    ADD CONSTRAINT dish_ingredients_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id);


--
-- Name: dish_ingredients dish_ingredients_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish_ingredients
    ADD CONSTRAINT dish_ingredients_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: expenses expenses_purchase_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_purchase_request_id_fkey FOREIGN KEY (purchase_request_id) REFERENCES public.purchase_requests(id);


--
-- Name: meal_pickups meal_pickups_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_pickups
    ADD CONSTRAINT meal_pickups_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: meal_pickups meal_pickups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_pickups
    ADD CONSTRAINT meal_pickups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: orders orders_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id) ON DELETE RESTRICT;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: procurement_requests procurement_requests_cook_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procurement_requests
    ADD CONSTRAINT procurement_requests_cook_id_fkey FOREIGN KEY (cook_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: procurement_requests procurement_requests_decided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procurement_requests
    ADD CONSTRAINT procurement_requests_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: purchase_requests purchase_requests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_requests
    ADD CONSTRAINT purchase_requests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: purchase_requests purchase_requests_decided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_requests
    ADD CONSTRAINT purchase_requests_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES public.users(id);


--
-- Name: reviews reviews_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dishes(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict Pcoln0brLAC1ut0bOM61Em256wMrSghbIibRihYupuvTh50IKvexO651y8Trejs


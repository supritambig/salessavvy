# 🛒 SalesSavvy — Full Stack E-Commerce App

A complete e-commerce platform combining a **Spring Boot REST API backend** and a **React (Vite) frontend**, packaged into a **single deployable JAR** — containerized with Docker and deployed on Kubernetes (kubeadm).

---

## 🏗️ Architecture

```
Browser
  └── http://<host>:9090
        └── Spring Boot (serves React SPA + REST API)
              ├── /                → React App (index.html)
              ├── /api/**          → Customer REST endpoints (JWT protected)
              └── /admin/**        → Admin REST endpoints (JWT + Role protected)
```

Both frontend and backend run on **port 9090** from a single JAR. No separate frontend server is needed in production.

---

## 🛠️ Tech Stack

| Layer         | Technology                                      |
|---------------|-------------------------------------------------|
| Backend       | Spring Boot 3.4.1, Spring Data JPA, JWT, BCrypt |
| Frontend      | React 18, Vite, React Router v6                 |
| Database      | MySQL 8.0                                       |
| Payments      | Razorpay                                        |
| Container     | Docker (multi-stage build)                      |
| Orchestration | Kubernetes (kubeadm)                            |

---

## 📦 Project Structure

```
salessavvy/
├── src/main/java/com/example/demo/
│   ├── SalessavvyApplication.java
│   ├── config/
│   │   └── SpaWebMvcConfig.java        ← Serves React SPA from Spring Boot
│   ├── entity/                         ← User, Product, Category, Order, CartItem, ...
│   ├── repository/                     ← JPA repositories
│   ├── service/                        ← AuthService, CartService, OrderService, ...
│   ├── controller/                     ← AuthController, CartController, ProductController, ...
│   ├── admincontrollers/               ← AdminProductController, AdminUserController, ...
│   ├── adminservices/                  ← AdminProductService, AdminUserService, ...
│   ├── filter/                         ← AuthenticationFilter (JWT cookie validation)
│   └── dto/                            ← LoginRequest, CartItemDetails
├── src/main/resources/
│   └── application.properties
├── frontend/                           ← React (Vite) source
│   ├── src/
│   │   ├── App.jsx, Routes.jsx, main.jsx
│   │   ├── LoginPage.jsx, RegistrationPage.jsx
│   │   ├── CustomerHomePage.jsx, CartPage.jsx, OrderPage.jsx
│   │   ├── AdminLogin.jsx, AdminDashboard.jsx
│   │   └── Header.jsx, Footer.jsx, Logo.jsx, ...
│   ├── package.json
│   └── vite.config.js
├── kube_scripts/
│   ├── db-statefulset-svc.yml
│   ├── app-deploy-svc.yml
│   └── setup-storage.sh
├── Dockerfile
├── docker_build_push.sh
├── k8s-deploy.sh
└── pom.xml                             ← Runs npm build automatically via frontend-maven-plugin
```

---

## 🔑 User Roles & Access

| Role     | How to get it                         | Pages                                              |
|----------|---------------------------------------|----------------------------------------------------|
| CUSTOMER | Register at `/register` → role=CUSTOMER | Home, Cart, Orders, Profile                      |
| ADMIN    | Register with role=ADMIN (or DB insert)| Admin Dashboard — Add/Delete Products, Manage Users, Business Analytics |

---

## ▶️ Running Locally (Dev Mode — 2 terminals)

### Prerequisites
- Java 17, Maven, Node 20, MySQL running locally

### Terminal 1 — Backend
```bash
# Update application.properties: change mysql-service → localhost
# spring.datasource.url=jdbc:mysql://localhost:3306/sales_savvy?createDatabaseIfNotExist=true

mvn spring-boot:run -pl . -Dspring-boot.run.skip-frontend=true
# Backend runs at http://localhost:9090
```

### Terminal 2 — Frontend (hot reload)
```bash
cd frontend
npm install
npm run dev
# React dev server at http://localhost:5174 (proxies /api and /admin to :9090)
```

---

## 📦 Build as Single JAR (Production)

```bash
# This builds React (npm run build), copies dist/ into static/, then packages the JAR
mvn clean package -DskipTests

# Run it
java -jar target/salessavvy-0.0.1-SNAPSHOT.jar

# App at http://localhost:9090 (React + API, single server)
```

---

## 🐳 Docker

```bash
# Build image (builds React + Spring Boot inside Docker)
docker build -t your_dockerhub_username/salessavvy:latest .

# Run with Docker Compose (quick local test)
docker network create ss-net

docker run -d --name mysql-service --network ss-net \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=sales_savvy \
  mysql:8.0

docker run -d --name salessavvy --network ss-net \
  -p 9090:9090 \
  your_dockerhub_username/salessavvy:latest

# Or use the build+push script
bash docker_build_push.sh
```

---

## ☸️ Kubernetes (kubeadm)

```bash
# 1. Update image in kube_scripts/app-deploy-svc.yml with your DockerHub username
# 2. Run the deploy script
bash k8s-deploy.sh
```

App will be available at: **http://\<NodeIP\>:30090**

### Useful kubectl commands
```bash
kubectl get pods
kubectl get svc
kubectl logs deployment/salessavvy -f
kubectl describe pod <pod-name>
kubectl rollout restart deployment/salessavvy
```

---

## 🗄️ Key API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/login` | Login (sets JWT cookie) |
| POST | `/api/auth/logout` | Logout |
| POST | `/api/users/register` | Register new user |
| GET  | `/api/products` | Get products (optionally filter by category) |
| GET  | `/api/cart/items` | Get cart items |
| POST | `/api/cart/add` | Add item to cart |
| PUT  | `/api/cart/update` | Update cart item quantity |
| DELETE | `/api/cart/delete` | Remove cart item |
| GET  | `/api/orders` | Get user's orders |
| POST | `/api/payment/create` | Create Razorpay order |
| POST | `/api/payment/verify` | Verify Razorpay payment |
| POST | `/admin/products/add` | Add product (ADMIN) |
| DELETE | `/admin/products/delete` | Delete product (ADMIN) |
| PUT  | `/admin/user/modify` | Modify user (ADMIN) |
| GET  | `/admin/business/monthly` | Monthly revenue report (ADMIN) |
| GET  | `/admin/business/overall` | Overall revenue (ADMIN) |

---

## ⚙️ Environment Variables (override in K8s or Docker)

| Variable | Default | Description |
|----------|---------|-------------|
| `SPRING_DATASOURCE_URL` | `jdbc:mysql://mysql-service:3306/sales_savvy` | MySQL URL |
| `SPRING_DATASOURCE_USERNAME` | `root` | DB username |
| `SPRING_DATASOURCE_PASSWORD` | `root` | DB password |
| `JWT_SECRET` | (see properties) | Must be ≥ 64 bytes |
| `RAZORPAY_KEY_ID` | test key | Replace with live key for production |
| `RAZORPAY_KEY_SECRET` | test secret | Replace with live secret |

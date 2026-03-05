# 🏨 OceanView Hotel Management System

A comprehensive web-based hotel management system built with Java Servlets, JSP, and MySQL. OceanView streamlines hotel operations including guest management, room reservations, and billing.

![Java](https://img.shields.io/badge/Java-17-orange)
![Servlet](https://img.shields.io/badge/Servlet-4.0-blue)
![JSP](https://img.shields.io/badge/JSP-2.3-green)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)

## ✨ Features

### Core Functionality
- Guest Management: NIC-based guest lookup with AJAX, add/edit guest profiles
- Reservation System: 3-step workflow (Guest → Dates → Room)
- Room Management: Real-time availability checking with date conflict detection
- Billing: Printable guest bills with PDF support
- Status Tracking: Reservation statuses (CONFIRMED, CHECKED_IN, CHECKED_OUT, CANCELLED) and payment tracking (PENDING, PARTIAL, PAID)

### User Interface
- Responsive dashboard with navigation
- Multi-step reservation forms with validation
- Search and filter reservations by status, date range, or keywords
- Real-time statistics and reporting

## 🗄️ Database Setup

CREATE DATABASE hotel_db;
-- Import schema from /sql/hotel_db_schema.sql

## 🔧 Configure Database Connection

Open `DBConnection.java` and update your MySQL credentials:

private static final String URL = "jdbc:mysql://localhost:3306/hotel_db";
private static final String USER = "root";
private static final String PASSWORD = "your_password";

## 🚀 Installation & Deployment

1. **Clone the repository**  
   git clone https://github.com/yourusername/oceanview-hotel.git  
   cd oceanview-hotel

2. **Deploy to Tomcat**  
   - Build WAR file (if using Maven):  
     mvn clean package  
   - Or copy the project folder to `webapps/` directory of Tomcat  
   - Start Tomcat server

3. **Access the Application**  
   Open your browser and navigate to:  
   http://localhost:8080/oceanview/index.jsp


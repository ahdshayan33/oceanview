<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("fullName") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help Center - OceanView Hotel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --info: #3b82f6;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-600: #475569;
            --gray-800: #1e293b;
            --white: #ffffff;
            --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
            --radius: 12px;
            --transition: all 0.3s ease;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--gray-100);
            color: var(--gray-800);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
        }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background: var(--white);
            border-right: 1px solid var(--gray-200);
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            z-index: 50;
            box-shadow: var(--shadow-lg);
        }

        .sidebar-header {
            padding: 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary) 0%, #0ea5e9 100%);
            border-radius: var(--radius);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        .logo-text {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .logo-text span { color: var(--primary); }

        .sidebar-nav {
            flex: 1;
            padding: 20px 16px;
        }

        .nav-section { margin-bottom: 24px; }

        .nav-section-title {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #94a3b8;
            padding: 0 12px;
            margin-bottom: 8px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 8px;
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: var(--transition);
            margin-bottom: 4px;
        }

        .nav-item:hover {
            background: var(--gray-50);
            color: var(--gray-800);
        }

        .nav-item.active {
            background: linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(14, 165, 233, 0.1) 100%);
            color: var(--primary);
            font-weight: 600;
        }

        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid var(--gray-200);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: var(--radius);
            background: var(--gray-50);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, #0ea5e9 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        .user-name {
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-800);
        }

        .logout-btn {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #94a3b8;
            text-decoration: none;
            border: 1px solid var(--gray-200);
        }

        .logout-btn:hover {
            background: var(--danger);
            color: white;
        }

        .main-content {
            flex: 1;
            margin-left: 280px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .top-header {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .dashboard-content {
            flex: 1;
            padding: 32px;
            max-width: 1000px;
        }

        /* Help Sections */
        .help-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .help-title {
            font-size: 32px;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .help-subtitle {
            color: #64748b;
            font-size: 16px;
        }

        .help-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }

        .help-card {
            background: var(--white);
            border-radius: var(--radius);
            padding: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            cursor: pointer;
            transition: var(--transition);
        }

        .help-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }

        .help-card-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 16px;
        }

        .help-card-icon.reservation { background: rgba(79, 70, 229, 0.1); }
        .help-card-icon.guest { background: rgba(16, 185, 129, 0.1); }
        .help-card-icon.room { background: rgba(245, 158, 11, 0.1); }
        .help-card-icon.system { background: rgba(59, 130, 246, 0.1); }

        .help-card-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .help-card-desc {
            font-size: 14px;
            color: #64748b;
        }

        /* Guide Sections */
        .guide-section {
            background: var(--white);
            border-radius: var(--radius);
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            display: none;
        }

        .guide-section.active {
            display: block;
        }

        .guide-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 2px solid var(--gray-200);
        }

        .guide-icon {
            width: 56px;
            height: 56px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }

        .guide-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-800);
        }

        .back-btn {
            margin-left: auto;
            padding: 8px 16px;
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
        }

        .back-btn:hover {
            background: var(--gray-200);
        }

        /* Steps */
        .step {
            margin-bottom: 24px;
            padding-left: 24px;
            border-left: 3px solid var(--primary);
        }

        .step-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            font-size: 14px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .step-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 8px;
        }

        .step-content {
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
        }

        .step-content ul {
            margin-top: 8px;
            margin-left: 20px;
        }

        .step-content li {
            margin-bottom: 4px;
        }

        /* Tips */
        .tip-box {
            background: rgba(59, 130, 246, 0.1);
            border-left: 4px solid var(--info);
            padding: 16px;
            border-radius: 0 8px 8px 0;
            margin: 16px 0;
        }

        .tip-box.warning {
            background: rgba(245, 158, 11, 0.1);
            border-left-color: var(--warning);
        }

        .tip-box.danger {
            background: rgba(239, 68, 68, 0.1);
            border-left-color: var(--danger);
        }

        .tip-title {
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Code/Path styling */
        code {
            background: var(--gray-100);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 13px;
            color: var(--primary);
        }

        /* Status badges reference */
        .badge-ref {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin: 4px 0;
        }

        .badge-small {
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .help-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">🏨</div>
            <div class="logo-text">Ocean<span>View</span></div>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="dashboard.jsp" class="nav-item">
                    <span style="width: 20px;">📊</span>
                    Dashboard
                </a>
                <a href="add-reservation" class="nav-item">
                    <span style="width: 20px;">➕</span>
                    Add Reservation
                </a>
                <a href="view-reservations" class="nav-item">
                    <span style="width: 20px;">📋</span>
                    View Reservations
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Management</div>
                <a href="guest-management" class="nav-item">
                    <span style="width: 20px;">👥</span>
                    Guest Management
                </a>
                <a href="room-status" class="nav-item">
                    <span style="width: 20px;">🚪</span>
                    Room Status
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Support</div>
                <a href="help.jsp" class="nav-item active">
                    <span style="width: 20px;">❓</span>
                    Help Center
                </a>
            </div>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="user-avatar"><%= fullName.charAt(0) %></div>
                <div>
                    <div class="user-name"><%= fullName %></div>
                    <div style="font-size: 12px; color: #64748b;">Administrator</div>
                </div>
                <a href="index.jsp" class="logout-btn">🚪</a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header class="top-header">
            <h1 class="page-title">Help Center</h1>
        </header>

        <div class="dashboard-content">
            
            <!-- Main Help Menu -->
            <div id="helpMenu">
                <div class="help-header">
                    <h2 class="help-title">How can we help you? 🤔</h2>
                    <p class="help-subtitle">Select a topic to learn more about using the OceanView Hotel Management System</p>
                </div>

                <div class="help-grid">
                    <div class="help-card" onclick="showGuide('reservations')">
                        <div class="help-card-icon reservation">📋</div>
                        <h3 class="help-card-title">Managing Reservations</h3>
                        <p class="help-card-desc">Learn how to create, view, and cancel reservations for guests</p>
                    </div>

                    <div class="help-card" onclick="showGuide('guests')">
                        <div class="help-card-icon guest">👥</div>
                        <h3 class="help-card-title">Guest Management</h3>
                        <p class="help-card-desc">Add new guests, update profiles, and search guest history</p>
                    </div>

                    <div class="help-card" onclick="showGuide('rooms')">
                        <div class="help-card-icon room">🚪</div>
                        <h3 class="help-card-title">Room Management</h3>
                        <p class="help-card-desc">Understand room statuses and how to manage room inventory</p>
                    </div>

                    <div class="help-card" onclick="showGuide('system')">
                        <div class="help-card-icon system">⚙️</div>
                        <h3 class="help-card-title">System Guide</h3>
                        <p class="help-card-desc">Navigation tips, keyboard shortcuts, and troubleshooting</p>
                    </div>
                </div>
            </div>

            <!-- Guide: Reservations -->
            <div id="guide-reservations" class="guide-section">
                <div class="guide-header">
                    <div class="guide-icon" style="background: rgba(79, 70, 229, 0.1);">📋</div>
                    <div>
                        <div class="guide-title">Managing Reservations</div>
                    </div>
                    <button class="back-btn" onclick="showMenu()">← Back to Help</button>
                </div>

                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-title">Creating a New Reservation</div>
                    <div class="step-content">
                        Navigate to <code>Add Reservation</code> from the sidebar or dashboard.
                        <ul>
                            <li><strong>Step 1 - Guest Lookup:</strong> Enter the guest's NIC number. If found, proceed. If not, register the guest first.</li>
                            <li><strong>Step 2 - Select Dates:</strong> Choose check-in and check-out dates. The system will show available rooms.</li>
                            <li><strong>Step 3 - Choose Room:</strong> Select from available rooms based on type and price.</li>
                            <li><strong>Confirmation:</strong> Review details and print the guest bill.</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-title">Viewing Reservations</div>
                    <div class="step-content">
                        Go to <code>View Reservations</code> to see all bookings.
                        <ul>
                            <li>Use filters: Status (Confirmed, Checked-in, etc.), Search (name/NIC/room), Date range</li>
                            <li>Statistics show counts for each status at the top</li>
                            <li>Click the 👁️ icon to view full details</li>
                            <li>Click 🖨️ to print the reservation details</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-title">Cancelling a Reservation</div>
                    <div class="step-content">
                        In <code>View Reservations</code>, find the booking and click the ❌ button.
                        <div class="tip-box warning">
                            <div class="tip-title">⚠️ Important</div>
                            Cancelling a reservation will:
                            <ul>
                                <li>Change status to CANCELLED</li>
                                <li>Free up the room immediately</li>
                                <li>Cannot be undone - create a new reservation if needed</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="tip-box">
                    <div class="tip-title">💡 Pro Tip</div>
                    Always verify guest NIC before creating a reservation. The system checks for existing guests automatically!
                </div>
            </div>

            <!-- Guide: Guests -->
            <div id="guide-guests" class="guide-section">
                <div class="guide-header">
                    <div class="guide-icon" style="background: rgba(16, 185, 129, 0.1);">👥</div>
                    <div>
                        <div class="guide-title">Guest Management</div>
                    </div>
                    <button class="back-btn" onclick="showMenu()">← Back to Help</button>
                </div>

                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-title">Adding a New Guest</div>
                    <div class="step-content">
                        Go to <code>Guest Management</code> → Click <strong>Add New Guest</strong>
                        <ul>
                            <li><strong>NIC (Required):</strong> National Identity Card number (unique)</li>
                            <li><strong>Full Name (Required):</strong> Guest's complete name</li>
                            <li><strong>Email & Phone:</strong> Contact information</li>
                            <li><strong>Address:</strong> Residential address</li>
                            <li><strong>Nationality:</strong> Country of origin</li>
                            <li><strong>Date of Birth:</strong> Format: YYYY-MM-DD</li>
                            <li><strong>Gender:</strong> Male/Female/Other</li>
                            <li><strong>Emergency Contact:</strong> Name and phone for emergencies</li>
                        </ul>
                        <div class="tip-box danger">
                            <div class="tip-title">🚫 NIC Cannot Be Changed!</div>
                            Once a guest is registered, their NIC cannot be modified. If there's a mistake, delete and recreate the guest profile.
                        </div>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-title">Searching Guests</div>
                    <div class="step-content">
                        Use the search bar in <code>Guest Management</code> to find guests by:
                        <ul>
                            <li>Name (partial match works)</li>
                            <li>NIC number</li>
                            <li>Phone number</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-title">Editing Guest Information</div>
                    <div class="step-content">
                        Find the guest in the list → Click <strong>Edit</strong>
                        <ul>
                            <li>All fields except NIC can be updated</li>
                            <li>Changes are saved immediately</li>
                            <li>Reservation history remains intact</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">4</div>
                    <div class="step-title">Deleting a Guest</div>
                    <div class="step-content">
                        Click the 🗑️ icon next to a guest.
                        <div class="tip-box warning">
                            <div class="tip-title">⚠️ Restriction</div>
                            You cannot delete a guest who has active reservations. Cancel or complete all their bookings first.
                        </div>
                    </div>
                </div>
            </div>

            <!-- Guide: Rooms -->
            <div id="guide-rooms" class="guide-section">
                <div class="guide-header">
                    <div class="guide-icon" style="background: rgba(245, 158, 11, 0.1);">🚪</div>
                    <div>
                        <div class="guide-title">Room Management</div>
                    </div>
                    <button class="back-btn" onclick="showMenu()">← Back to Help</button>
                </div>

                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-title">Understanding Room Statuses</div>
                    <div class="step-content">
                        <div class="badge-ref">
                            <span class="badge-small" style="background: rgba(16, 185, 129, 0.1); color: #059669;">VACANT</span>
                            <span>Room is clean and available for booking</span>
                        </div>
                        <div class="badge-ref">
                            <span class="badge-small" style="background: rgba(239, 68, 68, 0.1); color: #dc2626;">OCCUPIED</span>
                            <span>Currently has a guest checked in</span>
                        </div>
                        <div class="badge-ref">
                            <span class="badge-small" style="background: rgba(245, 158, 11, 0.1); color: #d97706;">CLEANING</span>
                            <span>Being cleaned after check-out, not yet available</span>
                        </div>
                        <div class="badge-ref">
                            <span class="badge-small" style="background: rgba(107, 114, 128, 0.1); color: #4b5563;">MAINTENANCE</span>
                            <span>Under repair, cannot be booked</span>
                        </div>
                        <div class="badge-ref">
                            <span class="badge-small" style="background: rgba(0, 0, 0, 0.1); color: #374151;">OUT_OF_ORDER</span>
                            <span>Not available for use</span>
                        </div>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-title">Viewing Room Status</div>
                    <div class="step-content">
                        Go to <code>Room Status</code> to see all rooms organized by floor.
                        <ul>
                            <li>Color-coded cards show room status at a glance</li>
                            <li>Occupied rooms show guest name and dates</li>
                            <li>Click any room to see details or change status</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-title">Room Types & Pricing</div>
                    <div class="step-content">
                        Available room types in the system:
                        <ul>
                            <li><strong>Standard:</strong> Basic amenities, city view</li>
                            <li><strong>Deluxe:</strong> Larger space, pool view</li>
                            <li><strong>Suite:</strong> Separate living area, premium amenities</li>
                            <li><strong>Presidential:</strong> Top floor, best view, luxury features</li>
                        </ul>
                        Base prices are set per room and can be adjusted during reservation creation.
                    </div>
                </div>

                <div class="tip-box">
                    <div class="tip-title">💡 Automatic Status Updates</div>
                    The system automatically updates room status when:
                    <ul>
                        <li>Reservation created → VACANT stays (until check-in day)</li>
                        <li>Guest checks in → OCCUPIED</li>
                        <li>Guest checks out → CLEANING</li>
                        <li>Reservation cancelled → VACANT</li>
                    </ul>
                </div>
            </div>

            <!-- Guide: System -->
            <div id="guide-system" class="guide-section">
                <div class="guide-header">
                    <div class="guide-icon" style="background: rgba(59, 130, 246, 0.1);">⚙️</div>
                    <div>
                        <div class="guide-title">System Guide</div>
                    </div>
                    <button class="back-btn" onclick="showMenu()">← Back to Help</button>
                </div>

                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-title">Navigation Tips</div>
                    <div class="step-content">
                        <ul>
                            <li><strong>Sidebar:</strong> Always visible on desktop, click ☰ on mobile</li>
                            <li><strong>Dashboard:</strong> Click logo or "Dashboard" to return home</li>
                            <li><strong>Quick Actions:</strong> Large cards on dashboard for frequent tasks</li>
                            <li><strong>Breadcrumbs:</strong> Track your location in the system</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-title">Keyboard Shortcuts</div>
                    <div class="step-content">
                        <ul>
                            <li><code>Alt + D</code> - Go to Dashboard</li>
                            <li><code>Alt + R</code> - Add Reservation</li>
                            <li><code>Alt + V</code> - View Reservations</li>
                            <li><code>Alt + G</code> - Guest Management</li>
                            <li><code>Esc</code> - Close modals/popups</li>
                            <li><code>Ctrl + P</code> - Print current page</li>
                        </ul>
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-title">Troubleshooting</div>
                    <div class="step-content">
                        <strong>Problem: "Error checking guest" when searching NIC</strong><br>
                        Solution: Check internet connection and refresh page. If persists, contact IT support.
                        
                        <br><br><strong>Problem: Room shows available but booking fails</strong><br>
                        Solution: Another user may have just booked it. Refresh and try again.
                        
                        <br><br><strong>Problem: Cannot delete a guest</strong><br>
                        Solution: Guest has active reservations. Cancel them first.
                        
                        <br><br><strong>Problem: Session expired / logged out unexpectedly</strong><br>
                        Solution: Login again. For security, the system logs you out after 30 minutes of inactivity.
                    </div>
                </div>

                <div class="step">
                    <div class="step-number">4</div>
                    <div class="step-title">Best Practices</div>
                    <div class="step-content">
                        <ul>
                            <li>✅ Always verify guest identity with NIC before check-in</li>
                            <li>✅ Print and give guest bill/receipt for every reservation</li>
                            <li>✅ Update room status to CLEANING immediately after check-out</li>
                            <li>✅ Double-check dates before confirming reservations</li>
                            <li>✅ Log out when leaving your workstation</li>
                            <li>❌ Never share your login credentials</li>
                            <li>❌ Don't delete guests with reservation history</li>
                            <li>❌ Avoid cancelling reservations unless necessary</li>
                        </ul>
                    </div>
                </div>

                <div class="tip-box">
                    <div class="tip-title">🆘 Need More Help?</div>
                    Contact IT Support:<br>
                    📧 Email: support@oceanview.lk<br>
                    📞 Phone: +94 11 234 5678 (Ext: 999)<br>
                    🕐 Available 24/7 for urgent issues
                </div>
            </div>

        </div>
    </main>

    <script>
        function showGuide(guideId) {
            // Hide menu
            document.getElementById('helpMenu').style.display = 'none';
            
            // Hide all guides
            document.querySelectorAll('.guide-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Show selected guide
            document.getElementById('guide-' + guideId).classList.add('active');
            
            // Scroll to top
            window.scrollTo(0, 0);
        }
        
        function showMenu() {
            // Show menu
            document.getElementById('helpMenu').style.display = 'block';
            
            // Hide all guides
            document.querySelectorAll('.guide-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Scroll to top
            window.scrollTo(0, 0);
        }
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.altKey && e.key === 'd') {
                window.location.href = 'dashboard.jsp';
            }
            if (e.altKey && e.key === 'r') {
                window.location.href = 'add-reservation';
            }
            if (e.altKey && e.key === 'v') {
                window.location.href = 'view-reservations';
            }
            if (e.altKey && e.key === 'g') {
                window.location.href = 'guest-management';
            }
        });
    </script>

</body>
</html>
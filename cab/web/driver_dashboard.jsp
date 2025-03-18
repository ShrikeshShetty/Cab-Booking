<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Driver Dashboard - Cab Booking System</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <h1>Driver Dashboard</h1><a href="logout.jsp">Logout</a>
    <% 
    Integer driverId = (Integer) session.getAttribute("userId");
    String userType = (String) session.getAttribute("userType");
    if (driverId == null || !"driver".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/5346cab";
    String user = "root";
    String dbPassword = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, dbPassword)) {
            // Fetch pending bookings
            try (CallableStatement stmt = conn.prepareCall("{call get_pending_bookings(?)}")) {
                stmt.setInt(1, driverId);
                ResultSet rs = stmt.executeQuery();
                out.println("<h2>Pending Bookings</h2>");
                out.println("<table border='1' id='pendingBookings'>");
                out.println("<tr><th>Booking ID</th><th>User</th><th>Pickup</th><th>Dropoff</th><th>Action</th></tr>");
                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getInt("booking_id") + "</td>");
                    out.println("<td>" + rs.getString("username") + "</td>");
                    out.println("<td>" + rs.getString("pickup_location") + "</td>");
                    out.println("<td>" + rs.getString("dropoff_location") + "</td>");
                    out.println("<td>");
                    out.println("<button onclick='acceptBooking(" + rs.getInt("booking_id") + ")'>Accept</button>");
                    out.println("<button onclick='rejectBooking(" + rs.getInt("booking_id") + ")'>Reject</button>");
                    out.println("</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }

            // Fetch available drivers using cursor
            out.println("<h2>Available Drivers</h2>");
            out.println("<table border='1'>");
            out.println("<tr><th>Driver ID</th><th>Name</th></tr>");
            try (CallableStatement stmt = conn.prepareCall("{call get_available_drivers(?)}")) {
                stmt.setInt(1, 5); // Limit to 5 drivers
                boolean hasResults = stmt.execute();
                while (hasResults) {
                    ResultSet rs = stmt.getResultSet();
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt(1) + "</td>");
                        out.println("<td>" + rs.getString(2) + "</td>");
                        out.println("</tr>");
                    }
                    hasResults = stmt.getMoreResults();
                }
            }
            out.println("</table>");
        }
    } catch (Exception e) {
        out.println("Error fetching data: " + e.getMessage());
    }
    %>
    <script>
    function acceptBooking(bookingId) {
        $.post("update_booking_status.jsp", {bookingId: bookingId, action: "accept"}, function(data) {
            alert(data);
            location.reload();
        });
    }

    function rejectBooking(bookingId) {
        $.post("update_booking_status.jsp", {bookingId: bookingId, action: "reject"}, function(data) {
            alert(data);
            location.reload();
        });
    }

    setInterval(function() {
        $.get("get_pending_bookings.jsp", function(data) {
            $("#pendingBookings").html(data);
        });
    }, 5000);
    </script>
</body>
</html>


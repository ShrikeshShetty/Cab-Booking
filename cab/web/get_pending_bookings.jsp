<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
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
    try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
         CallableStatement stmt = conn.prepareCall("{call get_pending_bookings(?)}")) {
        stmt.setInt(1, driverId);
        ResultSet rs = stmt.executeQuery();
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
    }
} catch (Exception e) {
    out.println("<tr><td colspan='5'>Error fetching pending bookings: " + e.getMessage() + "</td></tr>");
}
%>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

String url = "jdbc:mysql://localhost:3306/5346cab";
String user = "root";
String dbPassword = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
         CallableStatement stmt = conn.prepareCall("{call get_user_bookings(?)}")) {
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        out.println("<tr><th>Booking ID</th><th>Pickup</th><th>Dropoff</th><th>Status</th><th>Driver</th><th>Vehicle</th><th>Action</th></tr>");
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("booking_id") + "</td>");
            out.println("<td>" + rs.getString("pickup_location") + "</td>");
            out.println("<td>" + rs.getString("dropoff_location") + "</td>");
            out.println("<td>" + rs.getString("status") + "</td>");
            out.println("<td>" + (rs.getString("driver_name") != null ? rs.getString("driver_name") : "N/A") + "</td>");
            out.println("<td>" + (rs.getString("vehicle_details") != null ? rs.getString("vehicle_details") : "N/A") + "</td>");
            if ("Pending".equals(rs.getString("status"))) {
                out.println("<td><button onclick='cancelBooking(" + rs.getInt("booking_id") + ")'>Cancel</button></td>");
            } else {
                out.println("<td>N/A</td>");
            }
            out.println("</tr>");
        }
    }
} catch (Exception e) {
    out.println("<tr><td colspan='7'>Error fetching bookings: " + e.getMessage() + "</td></tr>");
}
%>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
Integer driverId = (Integer) session.getAttribute("userId");
String userType = (String) session.getAttribute("userType");
if (driverId == null || !"driver".equals(userType)) {
    response.sendRedirect("login.jsp");
    return;
}

int bookingId = Integer.parseInt(request.getParameter("bookingId"));
String action = request.getParameter("action");

String url = "jdbc:mysql://localhost:3306/5346cab";
String user = "root";
String dbPassword = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
         CallableStatement stmt = conn.prepareCall("{call update_booking_status(?, ?, ?)}")) {
        stmt.setInt(1, bookingId);
        stmt.setInt(2, driverId);
        stmt.setString(3, "accept".equals(action) ? "Accepted" : "Rejected");
        stmt.execute();
        out.print("Booking " + action + "ed successfully.");
    }
} catch (Exception e) {
    out.print("Error updating booking status: " + e.getMessage());
}
%>


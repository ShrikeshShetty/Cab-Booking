<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

int bookingId = Integer.parseInt(request.getParameter("bookingId"));

String url = "jdbc:mysql://localhost:3306/5346cab";
String user = "root";
String dbPassword = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
         CallableStatement stmt = conn.prepareCall("{call cancel_booking(?)}")) {
        stmt.setInt(1, bookingId);
        stmt.execute();
        out.print("Booking cancelled successfully.");
    }
} catch (Exception e) {
    out.print("Error cancelling booking: " + e.getMessage());
}
%>


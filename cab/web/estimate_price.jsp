<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
String pickup = request.getParameter("pickup");
String dropoff = request.getParameter("dropoff");

String url = "jdbc:mysql://localhost:3306/5346cab";
String user = "root";
String dbPassword = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
         PreparedStatement stmt = conn.prepareStatement("SELECT calculate_price(?, ?) AS price")) {
        stmt.setString(1, pickup);
        stmt.setString(2, dropoff);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            double price = rs.getDouble("price");
            out.print(String.format("%.2f", price));
        }
    }
} catch (Exception e) {
    out.print("Error estimating price: " + e.getMessage());
}
%>


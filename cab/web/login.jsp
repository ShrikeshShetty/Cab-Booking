<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Login - Cab Booking System</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .back{
            margin-left:-350px;
            margin-top: -40px
        }
    </style>
</head>
<body>
    <h1>Login</h1>
    <a href="index.jsp" class="back"> Back</a>
    <br><br><br>
    <% 
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");

        String url = "jdbc:mysql://localhost:3306/5346cab";
        String user = "root";
        String dbPassword = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
                 CallableStatement stmt = conn.prepareCall("{call login_user(?, ?, ?, ?, ?)}")) {
                stmt.setString(1, username);
                stmt.setString(2, password);
                stmt.setString(3, userType);
                stmt.registerOutParameter(4, Types.INTEGER);
                stmt.registerOutParameter(5, Types.VARCHAR);
                stmt.execute();
                
                int userId = stmt.getInt(4);
                String errorMessage = stmt.getString(5);
                
                if (userId > 0) {
                    session.setAttribute("userId", userId);
                    session.setAttribute("userType", userType);
                    if ("driver".equals(userType)) {
                        response.sendRedirect("driver_dashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                    return;
                } else {
                    out.println(errorMessage);
                }
            }
        } catch (Exception e) {
            out.println("Login failed. Error: " + e.getMessage());
        }
    }
    %>
    <form method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="userType">Login as:</label>
        <select id="userType" name="userType" required>
            <option value="user">User</option>
            <option value="driver">Driver</option>
        </select><br><br>
        <input type="submit" value="Login">
        <br><br>
        <p>Don't Have an Account? <a href="register.jsp">Register</a></p>
    </form>
</body>
</html>


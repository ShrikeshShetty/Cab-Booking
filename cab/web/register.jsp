<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Register - Cab Booking System</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .back{
            margin-left:-350px;
            margin-top: -40px
        }
    </style>
</head>
<body>
    <h1>Register</h1>
    <a href="index.jsp" class="back"> Back</a>
    <br><br><br>
    <% 
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phone");

        String url = "jdbc:mysql://localhost:3306/5346cab";
        String user = "root";
        String dbPassword = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, dbPassword);
                 CallableStatement stmt = conn.prepareCall("{call create_user(?, ?, ?, ?, ?)}")) {
                stmt.setString(1, username);
                stmt.setString(2, password);
                stmt.setString(3, email);
                stmt.setString(4, phoneNumber);
                stmt.registerOutParameter(5, Types.INTEGER);
                stmt.execute();
                int userId = stmt.getInt(5);
                response.sendRedirect("login.jsp");
                return;
            }
        } catch (Exception e) {
            out.println("Registration failed. Error: " + e.getMessage());
        }
    }
    %>
    <form method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br>

        <label for="phone">Phone Number:</label>
        <input type="tel" id="phone" name="phone" required><br>

        <input type="submit" value="Register">
        <br><br>
        <p>Already Have an Account? <a href="login.jsp">Login</a></p>
    </form>
</body>
</html>
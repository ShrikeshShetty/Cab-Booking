<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Book a Cab - Cab Booking System</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <h1>Book a Cab</h1>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <a href="logout.jsp">Logout</a>
    <% 
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String pickup = request.getParameter("pickup");
        String dropoff = request.getParameter("dropoff");

        String url = "jdbc:mysql://localhost:3306/5346cab";
        String user = "root";
        String dbPassword = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, dbPassword)) {
                // First, calculate the price using the function
                String priceQuery = "SELECT calculate_price(?, ?) AS price";
                try (PreparedStatement pstmt = conn.prepareStatement(priceQuery)) {
                    pstmt.setString(1, pickup);
                    pstmt.setString(2, dropoff);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        double price = rs.getDouble("price");
                        
                        // Now create the booking using the stored procedure
                        try (CallableStatement cstmt = conn.prepareCall("{call create_booking(?, ?, ?, ?, ?)}")) {
                            cstmt.setInt(1, userId);
                            cstmt.setString(2, pickup);
                            cstmt.setString(3, dropoff);
                            cstmt.registerOutParameter(4, Types.INTEGER);
                            cstmt.registerOutParameter(5, Types.DECIMAL);
                            cstmt.execute();
                            int bookingId = cstmt.getInt(4);
                            out.println("Booking created successfully. Booking ID: " + bookingId + ", Price: $" + String.format("%.2f", price));
                        }
                    }
                }
            }
        } catch (Exception e) {
            out.println("Booking failed. Error: " + e.getMessage());
        }
    }
    %>
    <form method="post" id="bookingForm">
        <label for="pickup">Pickup Location:</label>
        <input type="text" id="pickup" name="pickup" required><br>

        <label for="dropoff">Dropoff Location:</label>
        <input type="text" id="dropoff" name="dropoff" required><br>

        <label for="estimatedPrice">Estimated Price:</label>
        <span id="estimatedPrice">$0.00</span><br>

        <input type="submit" value="Book Now">
    </form>
    <br>
    
    <script>
    $("#pickup, #dropoff").on("change", function() {
        var pickup = $("#pickup").val();
        var dropoff = $("#dropoff").val();
        if (pickup && dropoff) {
            $.post("estimate_price.jsp", {pickup: pickup, dropoff: dropoff}, function(data) {
                $("#estimatedPrice").text("$" + parseFloat(data).toFixed(2));
            });
        }
    });
    </script>
</body>
</html>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Cab Booking System</title>
    <style>
        body {
            background: url("images/index-img.jpg") no-repeat center center fixed;
            background-size: cover;
            color: white;
            font-family: Arial, sans-serif;
            text-align: center;
            position: absolute;
            width: 100%;
            height: 100%;
            backdrop-filter: blur(5px)
        }

        

        h1 {
            margin-top: 50px;
            font-size: 2.5em;
        }

        nav ul {
            list-style: none;
            padding: 0;
        }

        nav ul li {
            display: inline;
            margin: 0 15px;
        }

        nav ul li a {
            text-decoration: none;
            color: white;
            font-size: 1.2em;
            font-weight: bold;
            padding: 10px 20px;
            border-radius: 5px;
            transition: background 0.3s;
        }

        nav ul li a:hover {
            background: rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <h1>Welcome to Cab Booking System</h1>
    <nav>
        <ul>
            <li><a href="register.jsp">Register</a></li>
            <li><a href="login.jsp">Login</a></li>
        </ul>
    </nav>
</body>
</html>

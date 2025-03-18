CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `pickup_location` varchar(100) NOT NULL,
  `dropoff_location` varchar(100) NOT NULL,
  `status` enum('Pending','Accepted','Rejected','Cancelled','Completed') DEFAULT 'Pending',
  `price` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`booking_id`),
  KEY `idx_bookings_user_id` (`user_id`),
  KEY `idx_bookings_driver_id` (`driver_id`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4;



CREATE TABLE `driver_notifications` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`notification_id`),
  KEY `idx_driver_notifications_driver_id` (`driver_id`),
  KEY `idx_driver_notifications_booking_id` (`booking_id`),
  CONSTRAINT `driver_notifications_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`),
  CONSTRAINT `driver_notifications_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `drivers` (
  `driver_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `vehicle_details` varchar(200) NOT NULL,
  `status` enum('Available','Busy') DEFAULT 'Available',
  PRIMARY KEY (`driver_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5347 DEFAULT CHARSET=utf8mb4;



CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;





delimiter \\
begin
    declare user_count int;
    declare driver_count int;   
    select count(*) into user_count from users;
    select count(*) into driver_count from drivers;  
    if user_count = 0 then
        insert into users (username, password, name, email) 
        values ('default_user', 'password123', 'default user', 'default@example.com');
    end if;    
    if driver_count = 0 then
        insert into drivers (username, password, name, email, vehicle_details) 
        values ('default_driver', 'password123', 'default driver', 'driver@example.com', 'default vehicle');
    end if;
end //
delimiter ;




delimiter //
create procedure login_user(
    in username varchar(50),
    in password varchar(50),
    in user_type varchar(10),
    out user_id int,
    out error_message varchar(100) )
begin
    declare temp_user_id int;
    declare temp_password varchar(50);   
    if user_type = 'user' then
        select user_id, password into temp_user_id, temp_password
        from users
        where username = username;
    else
        select driver_id, password into temp_user_id, temp_password
        from drivers
        where username = username;
    end if;
    if temp_user_id is null then
        set user_id = 0;
        set error_message = 'invalid username';
    elseif temp_password != password then
        set user_id = 0;
        set error_message = 'invalid password';
    else
        set user_id = temp_user_id;
        set error_message = null;
  end if;
end //
delimiter ;






delimiter  \\
create procedure create_booking(
    in user_id int,
    in pickup varchar(100),
    in dropoff varchar(100),
    out booking_id int,
    out price decimal(10, 2)
)
begin
    insert into bookings (user_id, pickup_location, dropoff_location, status)
    values (user_id, pickup, dropoff, 'pending');
    set booking_id = last_insert_id();
    set price = round(rand() * 50 + 10, 2);
        update bookings set price = price where booking_id = booking_id;
    insert into driver_notifications (driver_id, booking_id, message)
    select driver_id, booking_id, concat('new booking: ', pickup, ' to ', dropoff)
    from drivers
    where status = 'available';
end //
delimiter;






delimiter \\
create procedure get_pending_bookings(in driver_id int)
begin
    select b.booking_id, u.username, b.pickup_location, b.dropoff_location
    from bookings b
    join users u on b.user_id = u.user_id
    where b.status = 'pending'
    and b.booking_id in (
        select booking_id
        from driver_notifications
        where driver_id = driver_id
    );
end //
delimiter ;







delimiter \\
create procedure update_booking_status(
    in booking_id int,
    in driver_id int,
    in status varchar(20)
)
begin
    update bookings
    set status = status, driver_id = driver_id
    where booking_id = booking_id;
       if status = 'accepted' then
        delete from driver_notifications
       
where booking_id = booking_id;
        update drivers
        set status = 'busy'
        where driver_id = driver_id;
    end if;
end //
delimiter ;








delimiter \\
create procedure get_user_bookings(in user_id int)
begin
    select b.booking_id, b.pickup_location, b.dropoff_location, b.status,
           d.name as driver_name, d.vehicle_details
    from bookings b
    left join drivers d on b.driver_id = d.driver_id
    where b.user_id = user_id
    order by b.booking_id desc;
end //
delimiter ;









delimiter \\
create procedure cancel_booking(in booking_id int)
begin
    update bookings
    set status = 'cancelled'
    where booking_id = booking_id;
    
    delete from driver_notifications
    where booking_id = booking_id;
end //
delimiter ;






delimiter \\
create function calculate_price(
    pickup varchar(100),
    dropoff varchar(100)
) returns decimal(10, 2)
deterministic
begin
    declare temp_price decimal(10, 2);
    -- simplified price calculation based on string length difference
    set temp_price = round(abs(length(pickup) - length(dropoff)) * 0.5 + 10, 2);
    return temp_price;
end //
delimiter ;







delimiter \\
create trigger after_booking_update
after update on bookings
for each row
begin
    if new.status = 'accepted' then
        update drivers
        set status = 'busy'
        where driver_id = new.driver_id;
        delete from driver_notifications
        where booking_id = new.booking_id;
    elseif new.status = 'completed' or new.status = 'cancelled' then
        update drivers
        set status = 'available'
        where driver_id = new.driver_id;
    end if;
end //
delimiter ;







delimiter \\
create procedure get_available_drivers(in limit_val int)
begin
    declare finished int default 0;
    declare temp_driver_id int;
    declare temp_driver_name varchar(100);   
    declare driver_cursor cursor for 
        select driver_id, name 
        from drivers 
        where status = 'available'
        limit limit_val;
     declare continue handler for not found set finished = 1;
     open driver_cursor;
        driver_loop: loop
        fetch driver_cursor into temp_driver_id, temp_driver_name;
        if finished = 1 then
            leave driver_loop;
        end if;
        select temp_driver_id, temp_driver_name;
    end loop; 
close driver_cursor; 
end // 
delimiter ;
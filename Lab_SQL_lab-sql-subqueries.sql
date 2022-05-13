-- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film_id, count(inventory_id) as number_of_copies  
FROM sakila.inventory
where film_id in
(
select film_id
from sakila.film
where title in ('Hunchback Impossible')
);

-- List all films whose length is longer than the average of all the films.
select film_id, title, length
from sakila.film
where length >
(
select avg(length) 
from sakila.film
);

-- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id, concat(actor.first_name,' ',actor.last_name) as full_name
from sakila.actor
where actor_id in
(
select actor_id from
(
select film_id, actor_id
from sakila.film_actor
where film_id in
(
select film_id from 
(
select film_id, title
from sakila.film
where title in ('ALONE TRIP')
) sub1
)
) sub2
)
;
-- Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. Identify all movies categorized as family films

select film_id, title
from sakila.film
where film_id in 
(
select film_id from
(
select film_id, category_id
from sakila.film_category
where category_id in
(
select category_id from
(
select category_id, name
from sakila.category
where name in ('Family')
)sub1
)
)sub2
)
;
-- Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select concat(first_name,' ',last_name) as Canadians_lol, email
from sakila.customer
where address_id in
(
select address_id 
from sakila.address
where address_id in
(
select city.city_id
from sakila.city
where country_id in
(
select country_id from
(
select country_id, country
from sakila.country
where country in ('Canada')
)sub1
)
)
);

-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select film_id, title
from sakila.film
where film_id in
(
select film_id from
(
select film_id,actor_id
from sakila.film_actor
where actor_id in
(
select actor_id from
(
select actor_id, concat(first_name,' ',last_name) as full_name
from sakila.actor
where actor_id in
(
select actor_id from
(
select actor_id, count(actor_id) as Tally
from sakila.film_actor
group by actor_id
order by Tally desc
limit 1
) sub1
)
)sub2
)
)sub3
)
;

-- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select film_id, title
from sakila.film
where film_id in		
(
select film_id from
(
select inventory_id, film_id
from sakila.inventory
where inventory_id in
(
select inventory_id from
(
select customer_id, inventory_id
from sakila.rental
where customer_id in
(
select customer_id from
(
select customer_id, sum(amount) as total_spent
from sakila.payment
group by customer_id
order by total_spent desc
limit 1
)sub1
)
)sub2
)
)sub3
)
;
-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client :o
drop table if exists sakila.big_money;

create temporary table sakila.big_money
select customer_id, sum(amount) as spent
from sakila.payment
group by customer_id
having sum(amount) >
(
select avg(total_each) as avg_customer_spending
from
(
select customer_id, sum(amount) as total_each
from sakila.payment
group by customer_id
) sub1
)
;

use sakila;
select customer.customer_id, concat(customer.first_name,' ',customer.last_name) as patron, spent
from customer
join big_money
on customer.customer_id = big_money.customer_id
order by spent desc







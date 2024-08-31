Q1. Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1

============

Q2. Which country have the most invoices?

select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc

============

Q3. What are top 3 values of total invoices

select total from invoice
order by total desc
limit 3

============

Q4. Which has best customers?
--- we would like to throw a promotional music festival in the city 
--- we made the most money write a query that returns one city that has the highest sum of invoice totals
--- return both cit name and sum of invoice totals

select SUM(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc

============

Q5. Who is the best customer?
--- The customer who has spent the most money will be declared as best customer.
--- Write a query that returns the person who has spent most money

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

============

Q6. Write a query to return the email, firstname, lastname and genre of rock music listener
--- return your list ordered alphabetically by email starting with A?

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
)
order by email

============

Q7. Let's invite the artists who has written the most rock music in our dataset.
--- Write a query that returns the artist name and total track count of the top 10 rock bands?

SELECT artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
FROM track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs desc
limit 10;

============

Q8. Return all the track names that have a song length longer than the average song length.
--- Return the name and milliseconds.
--- For each track. Order by the song length with the longest song listed first

select name, milliseconds
from track
where milliseconds > (
select AVG(milliseconds) as avg_track_length
from track
)
order by milliseconds desc;

============

Q9. Find how much amount spent by each customers on artists?
--- write a query to return a customer name, artist name, and total spent

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track ON track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
FROM invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id 
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1, 2, 3, 4
order by 5 desc;

============

Q10. We want to find the most popular music Genre for each country.
--- We determine the most popular genre as the genre with the highest amount of purchases.
--- Write a query that returns each country along with the top genre
--- For countries where the maximum number of purchases is shared in return all the generes

with popular_genre as (
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc ) as RowNo
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1

--- Method 2

with recursive 
sales_per_country as (
select count(*) as purchase_per_genre, customer.country, genre.name, genre.genre_id
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2, 3, 4
order by 2
),
max_genre_per_country as (select max(purchase_per_genre) as max_genre_number, country
from sales_per_country
group by 2
order by 2)

select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchase_per_genre = max_genre_per_country.max_genre_number

============

Q11. Write a query that determines the customer that has spent the most on music for each country.
--- write a query that returns the country along with the top customer and how much they spent.
--- for countries where the top amount spent is shared, provide all customers who spent this amount.

with recursive 
customer_with_country as(
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 1,5 desc
),
country_max_spending as(
select billing_country, max(total_spending) as max_spending
from customer_with_country
group by billing_country
)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;

--- Method 2

with customer_with_country as (
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc)as RowNo
from invoice 
join customer on customer.customer_id = invoice.customer_id
group by 1, 2, 3, 4
order by 4 asc, 5 desc
)
select * 
from customer_with_country 
where RowNo <= 1

============

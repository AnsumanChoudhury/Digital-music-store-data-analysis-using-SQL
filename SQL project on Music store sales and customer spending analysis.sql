CREATE DATABASE music_database;
USE music_database;
select * from invoice_line;
select * from album2;
select * from employee;

# finding the senoir most employee
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

# which country have most invoices?
select * from invoice;
SELECT billing_country, COUNT(invoice_id) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 1;

# what are the top 3 values of total invoice?
SELECT invoice_id, total, billing_country
FROM invoice
ORDER BY total DESC
LIMIT 3;

# finding the city that has highest sum of invoice totals
SELECT billing_city, SUM(total) AS total_sum
FROM invoice
GROUP BY billing_city
ORDER BY total_sum DESC
LIMIT 1;

# finding the best customer- The customer who spend the most money will be declared as the best customer.
select * from customer;
SELECT *
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id;
SELECT customer.customer_id, SUM(invoice.total) AS total_sum
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_sum DESC, customer.customer_id DESC;

# Question set 2- Moderate
# write query to return email, first name, last name and genre of all rock music listners. return your list ordered alphabetically by email starting with a. 
select * from genre;
SELECT DISTINCT
    customer.email,
    customer.first_name,
    customer.last_name,
    genre.name as genre
FROM
    customer
JOIN
    invoice ON customer.customer_id = invoice.customer_id
JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN
    track ON invoice_line.track_id = track.track_id
JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name = 'Rock'
ORDER BY
    customer.email ASC;
    
# lets invite the artist who have written the most Rock music in our dataset. write the query to return the artist name and the total track count of top 10 Rock bands.
select * from genre;
select * from artist;
select * from album2;
select * from track;
SELECT
    artist.name as artist_name,
    COUNT(track.track_id) as total_track_count
FROM
    artist
JOIN
    album2 ON artist.artist_id = album2.artist_id
JOIN
    track ON album2.album_id = track.album_id
JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name = 'Rock'
GROUP BY
    artist.artist_id, artist.name
ORDER BY
    total_track_count DESC
LIMIT 10;

# return all the track names that have a song length greater than the average song length.
# return the name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select * from track;
SELECT
    name,
    milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY
    milliseconds DESC;
    
# Question set 3- Advance
#q1: find how much amount spent by each customer on artists? write a query to return customer name, artist name, total spent.
SELECT *
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album2 ON track.album_id = album2.album_id
JOIN artist ON album2.artist_id = artist.artist_id;
SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    artist.name AS artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent,
    SUM(SUM(invoice_line.unit_price * invoice_line.quantity)) OVER (PARTITION BY customer.customer_id) AS total_amount_spent
FROM
    customer
JOIN
    invoice ON customer.customer_id = invoice.customer_id
JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN
    track ON invoice_line.track_id = track.track_id
JOIN
    album2 ON track.album_id = album2.album_id
JOIN
    artist ON album2.artist_id = artist.artist_id
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, artist.artist_id, artist.name
ORDER BY
    customer.first_name, customer.last_name, amount_spent DESC;

# we want to find out the most popular music genre for each country. we determine the most popular genre as the genre with the highest amount of puchases.
# write the query that will return each country along with the top genre.
SELECT
    g.name AS genre_name,
    i.billing_country,
    SUM(il.quantity) AS total_quantity
FROM
    customer c
JOIN
    invoice i ON c.customer_id = i.customer_id
JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
JOIN
    track t ON il.track_id = t.track_id
JOIN
    genre g ON t.genre_id = g.genre_id
GROUP BY
    g.name, i.billing_country
ORDER BY
    i.billing_country DESC, total_quantity DESC;
    
# write a query that determines the customer that has spent the most on music for each country.
# write a query that returns the country along with the top customer and how much they spent.
WITH RankedCustomers AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spent,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS rnk
    FROM
        customer c
    JOIN
        invoice i ON c.customer_id = i.customer_id
    GROUP BY
        i.billing_country, c.customer_id, c.first_name, c.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    billing_country,
    total_spent
FROM
    RankedCustomers
WHERE
    rnk = 1
ORDER BY
    billing_country DESC, total_spent DESC;











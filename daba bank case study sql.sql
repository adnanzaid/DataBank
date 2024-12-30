create database case3;
use case3;

## 1. How many different nodes make up the Data Bank network?

select count(distinct node_id) as unique_node
from customer_nodes;

## 2. How many nodes are there in each region?
select region_id as region, count(node_id)
from customer_nodes 
inner join regions 
using (region_id)
group by region_id;

## 3. How many customers are divided among the regions?
select region_id , count(distinct customer_id) as customers
from customer_nodes
join regions 
using(region_id)
group by region_id;

## 4. Determine the total amount of transactions for each region name.
select r.region_name as region , sum(ct.txn_amount) as total_amount
from customer_transactions ct
join customer_nodes  cn on ct.customer_id = cn.customer_id
join regions r on cn.region_id = r.region_id
group by region 
order by region;

## 5.How long does it take on an average to move clients to a new node?

select round(avg(datediff(end_date , start_date)),2) as avg_days
from customer_nodes
where end_date != '9999-12-31';

## 6.What is the unique count and total amount for each transaction type

select distinct txn_type as transaction_type, count(*) as unique_count , sum(txn_amount) as total_transaction
from customer_transactions
group by txn_type;

## 7.What is the average number and size of past deposits across all customers

--  Divides the total number of deposit transactions by the total number of unique customers to calculate the average number of deposits per customer.

select round(count(customer_id)/(select count(distinct customer_id)
from customer_transactions)) as avg_deposit_count
from customer_transactions
where txn_type = 'deposit';

## 8.For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month

with databank_amount_transactions as 
(select customer_id ,  month(txn_date) as txn_month , 
sum(if(txn_type = 'deposit',1,0)) as deposit_count,
sum(if(txn_type = 'withdrawal',1,0)) as withdraw_count,
sum(if(txn_type = 'purchase',1,0)) as purchase_count
 from customer_transactions
 group by customer_id  , month(txn_date)
)

select txn_month , count(distinct customer_id) as number_of_customers
from databank_amount_transactions 
where deposit_count > 1
and (purchase_count =1 
    or withdraw_count = 1)
group by txn_month;




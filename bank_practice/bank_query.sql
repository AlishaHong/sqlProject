use bankdb;

# 1. BankDB 스키마를 만들고 CustomerAccount, TransactionHistory, CardUsageHistory 테이블을 생성합니다. 
# 별도 파일로 제출 


# 2. 각 테이블에 들어갈 데이터는 CustomerAccount(5개), Transaction History(50개), CardUsageHistory(30개)입니다.
# 테이블 조회 
select * from cardusage;
select * from cust_account;
select * from transactionhistory;


# 3. 가입 날짜가 오래된 고객 순으로 계좌 테이블 정렬 (이름, 가입 날짜, 계좌번호)

select * from cust_account
order by 가입일자;


# 4. 1~3월에 가입한 고객 조회 (이름, 가입 날짜, 계좌번호)

select * from cust_account
where month(가입일자) between "1" and "3";


# 5. 고객의 총 카드 사용 금액 조회 (날짜 제한 없음, 모든 데이터에서)

select c.고객명, sum(u.사용금액) "TotalSpent"
FROM cust_account c
INNER JOIN cardUsage u 
ON c.계좌번호 = u.계좌번호
group by c.고객명
having sum(u.사용금액);

select c.고객명, sum(u.사용금액) "totalSpent"
from cardUsage u, (select 계좌번호, 고객명 from cust_account) as c 
where c.계좌번호 = u.계좌번호
group by c.고객명
having sum(u.사용금액);


# 6. ‘김유나’의 총 카드 사용 금액 조회 (날짜 제한 없음, 모든 데이터에서)

select c.고객명, sum(u.사용금액) "TotalSpent"
FROM cust_account c
INNER JOIN cardUsage u ON c.계좌번호 = u.계좌번호
where 고객명 = "김유나"
group by c.고객명
having sum(u.사용금액);


# 7. ‘김유나’의 8월 1일 ~ 8월 17일까지 사용 금액 합계

select c.고객명, sum(u.사용금액) "TotalSpent"
FROM cust_account c
INNER JOIN cardUsage u ON c.계좌번호 = u.계좌번호
where 고객명 = "김유나" and 사용일자 between "2024-08-01" and "2024-08-17"
group by c.고객명
having sum(u.사용금액);


# 8. 전체 카드 사용 내역 중 금액이 15만원 이상 조회

select * from cardusage
where 사용금액 >= 150000;


# 9. 8월 한 달 동안 카드 사용 금액이 높은 순으로 정렬 

select c.고객명, sum(u.사용금액) "TotalSpentInAugust"
FROM cust_account c
INNER JOIN cardUsage u ON c.계좌번호 = u.계좌번호
group by c.고객명
having sum(u.사용금액)
order by TotalSpentInAugust desc;


# 10. 모든 사람의 8월 총 카드 사용 금액 계산 후 TransactionHistory 테이블에 ‘8월 카드값 출금’ 내용으로 삽입 (날짜.시간은 8월 31일 저녁 6시)
insert into transactionhistory(계좌번호, 입출금유형, 거래날짜, 거래시간, 입출금금액, 비고)

select
	c.계좌번호,
    '출금' as 입출금유형,
    '2024-08-31' as 거래날짜,
    '18:00:00' as 거래시간,
    sum(u.사용금액) as 입출금금액,
    '8월 카드값 출금' as 비고
from cust_account c

INNER JOIN cardUsage u ON c.계좌번호 = u.계좌번호
group by 계좌번호;

select * from transactionhistory;


# 11. 모두 0으로 적혀있는 Balance 를 계산하기 위해 TransactionHistory 테이블에서 모든 거래 내역 중 입금 금액은 값을 더하고 출금 금액은 값을 빼서 총액을 계산하여 Balance 컬럼 값 업데이트 후 조회

# 입금총합 
select 계좌번호, sum(입출금금액) as "입금총합"
from transactionhistory
where 입출금유형 = '입금'
group by 계좌번호;
    
# 출금총합
select 계좌번호, sum(입출금금액) as "출금총합"
from transactionhistory
where 입출금유형 = '출금'
group by 계좌번호;

# 조인하여 업데이트
update cust_account c
join (
	select 계좌번호, sum(입출금금액) as "입금총합"
	from transactionhistory
	where 입출금유형 = '입금'
	group by 계좌번호
    ) as deposit

on c.계좌번호 = deposit.계좌번호

join (
	select 계좌번호, sum(입출금금액) as "출금총합"
	from transactionhistory
	where 입출금유형 = '출금'
	group by 계좌번호
) as withdraw 

on c.계좌번호 = withdraw.계좌번호

set c.잔액 = 0 + deposit.입금총합 - withdraw.출금총합;

select * from cust_account;

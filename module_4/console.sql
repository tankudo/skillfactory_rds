-- 4.1
-- База данных содержит список аэропортов практически всех крупных
-- городов России. В большинстве городов есть только один аэропорт.
-- Исключение составляет:

select city
from dst_project.airports
group by airports.city
having count(city) > 1;


-- 4.2.1
-- Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих
-- и запланированных рейсах. Сколько всего статусов для рейсов
-- определено в таблице?

with ct as (
    select status
    from dst_project.flights
    group by status
)
select count(status)
from ct;

-- 4.2.2
-- Вопрос 2. Какое количество самолетов находятся в
-- воздухе на момент среза в базе (статус рейса «самолёт
-- уже вылетел и находится в воздухе»).

select count(status),
       status
from dst_project.flights
where status = 'Departed'
group by status;

-- 4.2.3 Вопрос 3. Места определяют схему салона каждой модели.
-- Сколько мест имеет самолет модели  773 (Boeing 777-300)?

select count(aircraft_code)
from dst_project.seats
where aircraft_code = '773';

-- 4.2.4 Вопрос 4. Сколько состоявшихся (фактических)
-- рейсов было совершено между 1 апреля 2017 года и 1 сентября 2017 года?

select count(flight_id)
from dst_project.flights f
where f.scheduled_arrival between '2017-04-01 00:00:00'
    and '2017-09-01 00:00:00'
  and f.status = 'Arrived';

-- 4.3.1 Вопрос 1. Сколько всего рейсов было отменено по данным базы?

select count(f.flight_id)
from dst_project.flights f
where f.status = 'Cancelled';

-- 4.3.2
-- Вопрос 2. Сколько самолетов моделей типа Boeing, Sukhoi Superjet,
-- Airbus находится в базе авиаперевозок?

select sum((model LIKE 'Boeing%')::int)
           Boeings,
       sum((model LIKE 'Sukhoi%')::int)
           Sukhoi,
       sum((model LIKE 'Airbus%')::int)
           Airbuses
from dst_project.aircrafts;

-- 4.3.3
-- Вопрос 3. В какой части (частях) света находится больше аэропортов?

select (
           select count(timezone)
           from dst_project.airports
           where timezone like 'Asia%'
       ) as Asia,
       (
           select count(timezone)
           from dst_project.airports
           where timezone like 'Australia%'
       ) as Australia,
       (
           select count(timezone)
           from dst_project.airports
           where timezone like 'Europe%'
       ) as Europe
from dst_project.airports
limit 1;

-- 4.3.4
-- Вопрос 4. У какого рейса была самая большая задержка
-- прибытия за все время сбора данных? Введите id рейса (flight_id).

select flight_id
from dst_project.flights
where actual_arrival is not null
order by actual_arrival - scheduled_arrival desc
limit 1;

-- 4.4.1
-- Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?

select scheduled_departure
from dst_project.flights
order by 1
limit 1;

-- 4.4.2 Вопрос 2. Сколько минут составляет запланированное время
-- полета в самом длительном рейсе?

select extract(
               hour
               from
               (
                   scheduled_arrival - scheduled_departure
                   ) * 60
           )
from dst_project.flights
order by 1 desc
limit 1;

-- 4.4.3 Вопрос 3. Между какими аэропортами пролегает самый
-- длительный по времени запланированный рейс?

select departure_airport,
       arrival_airport
from dst_project.flights
order by scheduled_arrival - scheduled_departure desc
limit 1;

-- 4.4.4 Вопрос 4. Сколько составляет средняя дальность
-- полета среди всех самолетов в минутах? Секунды округляются
-- в меньшую сторону (отбрасываются до минут).

select avg(
               (
                   extract(
                           hour
                           from
                           (
                               scheduled_arrival - scheduled_departure
                               ) * 60
                       )
                   )
           )
from dst_project.flights
order by 1 desc;

-- 4.5.1
-- Вопрос 1. Мест какого класса у SU9 больше всего?

select count(fare_conditions),
       fare_conditions
from dst_project.seats s
         join dst_project.aircrafts a on s.aircraft_code = a.aircraft_code
where s.aircraft_code = 'SU9'
group by fare_conditions;

-- 4.5.2
-- Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?

select min(total_amount)
from dst_project.bookings;

-- 4.5.3
-- Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?

select bp.seat_no
from dst_project.tickets t
         join dst_project.ticket_flights tf on t.ticket_no = tf.ticket_no
         join dst_project.boarding_passes bp on tf.ticket_no = bp.ticket_no
where passenger_id = '4313 788533';

-- 5.1.1
-- Вопрос 1. Анапа — курортный город на юге России.
-- Сколько рейсов прибыло в Анапу за 2017 год?

select count(*)
from dst_project.flights
where (arrival_airport = 'AAQ')
  and (status = 'Arrived')
  and (date_part('year', actual_arrival) = 2017);

-- 5.1.2
-- Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?

SELECT count(airport_code)
FROM dst_project.airports a
         join dst_project.flights f on a.airport_code = f.arrival_airport
where city = 'Anapa'
  and extract(
              year
              from
              scheduled_departure
          ) = 2017
  and (
            extract(
                    month
                    from
                    scheduled_departure
                ) = 12
        or extract(
                   month
                   from
                   scheduled_departure
               ) < 3
    );

-- 5.1.3
-- Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.

SELECT count(*)
FROM dst_project.airports a
         join dst_project.flights f on a.airport_code = f.arrival_airport
where city = 'Anapa'
  and status = 'Cancelled';

-- 5.1.4
-- Вопрос 4. Сколько рейсов из Анапы не летают в Москву?

SELECT count(airport_code)
FROM dst_project.airports a
         join dst_project.flights f on a.airport_code = f.arrival_airport
where arrival_airport not in (
    SELECT airport_code
    FROM dst_project.airports a
             join dst_project.flights f on a.airport_code = f.arrival_airport
    where city = 'Moscow'
)
  and departure_airport in (
    SELECT airport_code
    FROM dst_project.airports a
             join dst_project.flights f on a.airport_code = f.arrival_airport
    where city = 'Anapa'
);

-- 5.1.5
-- Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?

SELECT model,
       count(seat_no)
FROM dst_project.airports a
         join dst_project.flights f on a.airport_code = f.arrival_airport
         join dst_project.aircrafts c on f.aircraft_code = c.aircraft_code
         join dst_project.seats s on s.aircraft_code = c.aircraft_code
where departure_airport in (
    SELECT airport_code
    FROM dst_project.airports a
             join dst_project.flights f on a.airport_code = f.arrival_airport
    where city = 'Anapa'
)
group by model;

-- Запрос по всей базе данных

with countSold (flight_id, sold, avgprice) as
         (select f.flight_id,
                 count(t.ticket_no) over (partition by f.flight_id),
                 avg(t.amount) over (partition by f.flight_id)
          from dst_project.flights f
                   join dst_project.ticket_flights t on f.flight_id = t.flight_id),
     countSeats
         (availableSeats, model)
         as (select count(s.seat_no) over (partition by ar.model),
                    ar.model
             from dst_project.seats s
                      join dst_project.aircrafts ar on s.aircraft_code = ar.aircraft_code)
select f.flight_id,
       sold,
       scheduled_departure,
       scheduled_arrival,
       t.avgprice,
       a.latitude,
       a.longitude,
       a.airport_code,
       ar.model,
       c.availableSeats
from dst_project.flights f
         join countSold t on f.flight_id = t.flight_id
         join dst_project.airports a on a.airport_code = f.arrival_airport
         join dst_project.aircrafts ar on ar.aircraft_code = f.aircraft_code
         join countSeats c on c.model = ar.model
WHERE f.departure_airport = 'AAQ'
  AND (date_trunc('month', f.scheduled_departure) IN ('2017-01-01',
                                                      '2017-02-01',
                                                      '2017-12-01'))
  AND f.status NOT IN ('Cancelled')
group by 1, t.sold, t.avgprice, a.latitude, a.longitude, a.airport_code, c.availableSeats, ar.model
order by 1;
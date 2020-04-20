/*Executar scripts em um banco mySql*/

create database if not exists barbearia_db;
use barbearia_db;

create table if not exists login_tab(
	  login_id_pk int primary key auto_increment,
	  login_email varchar(100) not null unique,
    login_password varchar(30) not null,
    locked char(1) not null default 0 comment 'bloquear após 3 tentativas incorretas',
    locked_date_start datetime default null,
    locked_date_end datetime default null,
    active char(1) default 1,
    rowversion datetime default current_timestamp
);

create table if not exists customers_tab(
	  customer_id_pk int primary key auto_increment,
	  customer_name varchar (100) not null,
    sexo char(1) default null comment 'F para feminino e M para masculino',
    login_fk int not null,
	  rowversion datetime	default current_timestamp,
    
    constraint foreign key (login_fk) references login_tab (login_id_pk) on delete cascade
);

create table if not exists address_category_tab(
	  address_cat_id_pk int primary key auto_increment,
    category varchar(20) not null unique
);

create table if not exists customer_address_tab(
	  address_id_pk int primary key auto_increment,
    default_method char(1) default 0 comment 'Método de comunicação padrão com o usuário',
    category varchar(20) not null comment 'Meio de comunicação'
		check(category in(select distinct a.category from address_category_tab a order by a.category)),
    value_text varchar(100) not null,
    customer_id_fk int not null,
    rowversion datetime default current_timestamp,
    
    constraint foreign key (customer_id_fk) references customers_tab (customer_id_pk) on delete cascade
);

create table if not exists staff_tab(
	  staff_id_pk int primary key auto_increment,
    staff_name varchar(100) not null,
    sexo char(1) default null comment 'F para feminino e M para masculino',
    staff_cpf_cnpj varchar(20) not null unique,
    active char(1) default 1 comment 'Barbeiro ativo ou não ativo',
    rowversion datetime default current_timestamp
);

create table if not exists staff_calendar_tab(
	  staff_calendar_id_pk int primary key auto_increment check(auto_increment = 10),
    staff_id_fk int not null,
    day_of_week varchar(3) not null check(dia_semana in('DOM','SEG','TER','QUA','QUI','SEX','SAB')),
    time_from time not null comment 'horário de inicio do atendimento',
    time_to time not null comment 'horário do término do atendimento',
    active char(1) default 1 comment 'dia da semana é ativo',
    rowversion datetime default current_timestamp,
    
    constraint foreign key (staff_id_fk) references staff_tab (staff_id_pk) on delete cascade
);

create table if not exists calendar_tab(
	  calendar_id_pk int primary key auto_increment check(auto_increment = 5),
    staff_id_fk int not null,
    customer_id_fk int not null,
    target_date datetime not null comment 'Data e hora marcada',
    cancelled char(1) not null default 0 comment 'Agendamento cancelado sim ou não',
    completed char(1) not null default 0 comment 'Marcação de atendimentos concluídos',
    observation varchar(150) comment 'Observações do cliente para o agendamento. Opcional',
    rowversion datetime default current_timestamp,
    
    constraint foreign key (staff_id_fk) references staff_tab (staff_id_pk) on delete cascade,
    constraint foreign key (customer_id_fk) references customers_tab (customer_id_pk) on delete cascade
);





/*views*/
create or replace view calendar as(select * from barbearia_db.calendar_tab);
create or replace view customer_address as(select * from barbearia_db.customer_address_tab);
create or replace view customers as(select * from barbearia_db.customers_tab);
create or replace view login as(select * from barbearia_db.login_tab);
create or replace view staff as(select * from barbearia_db.staff_tab);
create or replace view staff_calendar as(select * from barbearia_db.staff_calendar_tab);
create or replace view agenda_atualizada as (
	select a.staff_name		as NOME_COLABORADOR,
		   (select distinct x.customer_name
			  from customers x
			 where x.customer_id_pk = c.customer_id_fk) as CLIENTE,
		   c.target_date	as HORARIO_MARCADO,
		   c.observation	as OBS_CLIENTE,
		   d.value_text		as CONTATO
	  from staff a
	 inner join calendar c
		on c.staff_id_fk = a.staff_id_pk
	 inner join customer_address d
		on d.customer_id_fk = c.customer_id_fk
	 where d.default_method = '1'
	   and d.category = 'CELULAR'
	   and c.completed = '0'
	   and c.cancelled <> '1'
	 order by a.staff_name
);


insert into address_category_tab(category) values('CELULAR'), ('ENDEREÇO'), ('E-MAIL');
insert into address_category_tab(category) values('FAX'), ('CAIXA POSTAL'), ('WHATSAPP');
insert into address_category_tab(category) values('TWITTER'), ('FACEBOOK'), ('INSTAGRAN');


insert into login_tab(login_email, login_password) values('joao@gmail.com','1111');
insert into login_tab(login_email, login_password) values('maria@gmail.com','2222');
insert into login_tab(login_email, login_password) values('pedro@gmail.com','333');

insert into customers_tab(customer_name, sexo, login_fk) values ('JOÃO CARLOS SOUZA','M', 1);
insert into customers_tab(customer_name, sexo, login_fk) values ('MARIA EDUARDA PEREIRA','F', 2);
insert into customers_tab(customer_name, sexo, login_fk) values ('PEDRO ROBERTO ALVES','2', 3);

insert into customer_address_tab(category, value_text, customer_id_fk) values('CELULAR', '1195685-5900', 1);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('E-MAIL', 1,'joao@gmail.com', 1);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('CELULAR', 1, '1195685-6000', 1);
insert into customer_address_tab(category, value_text, customer_id_fk) values('CELULAR', '1197685-2001', 2);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('E-MAIL', 1,'maria@gmail.com', 2);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('CELULAR', 1, '1194569-7000', 2);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('WHATSAPP', 1, '1195699-1111', 3);
insert into customer_address_tab(category, default_method, value_text, customer_id_fk) values('TWITTER', 0, '@pedroalves', 3);



insert into staff_tab(staff_name, sexo, staff_cpf_cnpj) values('PAULO LOPES','M','25698569855');
insert into staff_tab(staff_name, sexo, staff_cpf_cnpj) values('ANDRESSA LOPES','F','25698569966');
insert into staff_tab(staff_name, sexo, staff_cpf_cnpj) values('LAURA LOPES','F','25698569044');


insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(1,'SAB','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(1,'DOM','09:00:00','15:00:00');

insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'SEG','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'TER','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'QUA','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'QUI','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'SEX','09:00:00','16:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(2,'SAB','09:00:00','17:00:00');

insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(3,'SEG','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(3,'TER','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(3,'QUA','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(3,'QUI','09:00:00','17:00:00');
insert into staff_calendar_tab(staff_id_fk, day_of_week, time_from, time_to)
value(3,'SAB','09:00:00','17:00:00');


insert into calendar_tab(staff_id_fk, customer_id_fk, target_date) value(1, 1, '2020-04-20 10:00:00');
insert into calendar_tab(staff_id_fk, customer_id_fk, target_date) value(3, 2, '2020-04-20 10:00:00');



/*Horário de trabalho por colaborador*/
select a.staff_name		as NOME_COLABORADOR,
	   a.staff_cpf_cnpj as CPFCNPJ,
       b.day_of_week	as DIA_DA_SEMANA,
       b.time_from		as INICIO_ATEND,
       b.time_to		as TERM_ATEND,
       b.active 		as ATIVO,
       (b.time_to - b.time_from) as PERIODO
  from staff a
 inner join staff_calendar b
    on a.staff_id_pk = b.staff_id_fk
 order by a.staff_name;


/*Agenda de horário marcados por cliente*/
select a.staff_name		as NOME_COLABORADOR,
	   (select distinct x.customer_name
		  from customers x
		 where x.customer_id_pk = c.customer_id_fk) as CLIENTE,
       c.target_date	as HORARIO_MARCADO,
       c.observation	as OBS_CLIENTE,
       d.value_text		as CONTATO
  from staff a
 inner join calendar c
    on c.staff_id_fk = a.staff_id_pk
 inner join customer_address d
    on d.customer_id_fk = c.customer_id_fk
 where d.default_method = '1'
   and d.category = 'CELULAR'
   and c.completed = '0'
   and c.cancelled <> '1'
 order by a.staff_name;


select c.customer_id_pk, c.customer_name, a.category, a.value_text
  from customers c
 inner join customer_address a
    on customer_id_fk = customer_id_pk
 where customer_id_pk in(select distinct x.customer_id_pk from customers x)
   and a.default_method = 1;
   
   
select * from agenda_atualizada;

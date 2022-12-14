create database sinhvien
go
use sinhvien
go
create table Lop
(
	Malop nvarchar(5) not null,
	TenLop nvarchar(20) not null,
	SiSo int not null
	CONSTRAINT pk_lop  primary key  (Malop)
)
create table Sinhvien
(
	MaSV nvarchar(10) not null,
	Hoten nvarchar(50) not null,
	NgaySinh smalldatetime not null,
	Malop nvarchar(5) not null
	CONSTRAINT pk_masv primary key (MaSV)
)
create table MonHoc
(
	MaMH nvarchar(10) not null,
	TenMH nvarchar(50) not null,
	CONSTRAINT pk_mamh primary key (MaMH)
)
create table KetQua
(
	MaSV nvarchar(10) not null,
	MaMH nvarchar(10) not null,
	Diemthi float not null
)
go
alter table Sinhvien
with check add
CONSTRAINT fk_lop_sinhvien foreign key (Malop) references Lop(Malop)

alter table KetQua
with check add
CONSTRAINT fk_monhoc_ketqua foreign key (MaMH) references MonHoc(MaMH)

alter table KetQua
with check add
CONSTRAINT fk_sinhvien_ketqua foreign key (MaSV) references Sinhvien(MaSV)
insert into Lop values ('L01','Tn',6)
insert into Lop values ('L02','Kh',7)
insert into Lop values ('L03','Xh',8)
insert into Sinhvien values ('001','vxat',cast('2001-04-19' as date), 'L01')
insert into Sinhvien values ('002','vxat1',cast('2002-12-04' as date), 'L02')
insert into Sinhvien values ('003','vxat2',cast('2000-07-20' as date), 'L03')
insert into MonHoc values ('mh01','TD')
insert into MonHoc values ('mh02','CSDL')
insert into MonHoc values ('mh03','QTM')
insert into KetQua values ('001','mh01',8.7)
insert into KetQua values ('001','mh02',7.7)
insert into KetQua values ('003','mh01',9.1)
insert into KetQua values ('002','mh02',8)
insert into KetQua values ('001','mh03',8)
insert into KetQua values ('003','mh02',8.7)
go
------------Câu 1
create function diemtb(@masv nvarchar(10))
returns float 
as 
begin
return(select (avg(Diemthi)) from KetQua where @masv = MaSV)
end
go
print('Điểm trung bình là: '+CONVERT(nvarchar,dbo.diemtb('002')))
-------------Câu 2
create function Tinhdiem(@malop nvarchar(10))
returns table 
as 
return
	select s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
 from Sinhvien s join KetQua k on s.MaSV=k.MaSV
 where MaLop=@malop
 group by s.masv, Hoten
go
create function trbinhlop(@malop nvarchar(10))
returns @dsdiemtb table (masv char(5), tensv nvarchar(20), dtb float)
as
begin
 insert @dsdiemtb
 select s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
 from Sinhvien s join KetQua k on s.MaSV=k.MaSV
 where MaLop=@malop
 group by s.masv, Hoten
 return
end
go
select * from trbinhlop('L01')
---------Câu 3 
create proc kiemtra @masv nvarchar(10)
as
begin
 declare @dem int
 set @dem=(select count(*) from ketqua where Masv=@masv)
 if @dem = 0
 print 'sinh vien '+@masv + ' khong thi mon nao'
 else
 print 'sinh vien '+ @masv+ ' thi '+cast(@dem as nvarchar(10))+ 'mon'
end
go
exec kiemtra '001'

-----------Câu 4 
create trigger kt_ss
on sinhvien for insert
as
begin
 declare @siso int
 set @siso=(select count(*) from sinhvien s
 where malop in(select malop from inserted))
 if @siso > 10
	 begin
	print 'Lop day'
	rollback tran
	end
	else
	begin
		 update lop
		set SiSo=@siso
		where malop in (select malop from inserted)
 end
 end
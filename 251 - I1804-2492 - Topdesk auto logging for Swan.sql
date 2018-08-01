--251 - I1804-2492 - Campbell McMichael - Topdesk auto logging for Swan

-- Syed has provided a list of organisations and their 'ID' that should be matched against an organisation.

/*
ID
Organization Name
abellio
Abellio
abellio-uk
Abellio-UK-Bus
borchard
Borchard Lines
calsonic
Calsonic Kansei
ccc
Coventry City Council
cdt
Cambridge Display Technology
edmundson-electrical
Edmundson Electrical Ltd
efrs
Essex County Fire & Rescue Service
first-group
First Group PLC
furniture-village
Furniture Village
grj
Great Rail Journeys
harwood
Harwood Capital
hrbs
Hinckley & Rugby Building Society
inoapps
Inoapps
jhp
James Hambro & Partners
jrp
John Rowan & Partners
kmbc
Knowsley Metropolitan Borough Council
lth
Leeds Teaching Hospital
mcginley-group
McGinley Group
mss
McGinley Support Services
nice-pak
Nice-Pak International
paperchase
Paperchase
raven-russia
Raven Russia
renewi
Renewi
swan-retail
Swan Retail
tlby
The Lakes by Yoo
twc
TWC
william-hill
William Hill
*/

-- Look at the extraa table for organisation.  I expect that when the email comes into TOPDesk, we want to interrogate the TOPdesk incident table for 'Kaseya'.

--select top 100 e.naam, * from extraa e
--where e.naam = '%kaseya%' -- zero rows.

---- mcginley.
--select top 100 e.naam, * from extraa e
--where e.naam like '%mcginley%' -- two rows returned.  McGinley Group and McGinley Support Services.

-- What's the caller name for Incident: 'I1802-1877'
use topdesklive
go
select i.aanmeldernaam, i.persoonid, p.unid, p.ref_dynanaam, i.* 
from incident i 
join persoon p
on i.persoonid = p.unid
where i.naam = 'I1802-1877'

select p.unid, p.ref_dynanaam, * from persoon p where p.unid = '23DD1203-AB81-44CF-B707-A884F0D3E777'

-- How can we interrogate the subject of an email.  See incident.korteomschrijving field.  This is the 
select * from incident i where i.naam = 'I1804-2492'
-- Note, in the mail import, there is a setting to copy the subject of the email to the brief description field 

korteomschrijving
FW: Topdesk auto logging for Swan
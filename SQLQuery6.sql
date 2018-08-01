USE TOPDESK575
GO

/****** Object:  Trigger [dbo].[Esteem_Incident_Calculate_Units]    Script Date: 07/03/2017 13:35:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:           John Della Pietra/Campbell McMichael/Zishan Qureshi
-- Create date: 07/Mar/2017
-- Description: The purpose behind this Trigger is to populate the time_registration_incident table with 4 records.  This will be 
-- reflected in the TopDesk Time Registration tab of an incident.  The records are for Departure Time, Arrival Time, Onsite Time and Travel Time
-- Change History;
--
-- Date                           Who                                      Ref                         Reason
-- ----             ---                     ---             ------
-- 19/05/2016        C. McMichael               C1605-0051           Re-Open incidents
-- 05/08/2016        CM                                       Satellite            Audit optional fields
-- 12/09/2016        CM                                       C1607-0043           Improve FSR data entry performance
--
-- =============================================

CREATE TRIGGER IncidentTimeRegitration
   ON incident__memogeschiedenis
   AFTER insert
AS 

BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;

--START of code.....
       DECLARE @IncidentID  UNIQUEIDENTIFIER;
       SELECT @IncidentID = UNID FROM inserted; --verify which incident we are looking at.

       --insert into mik1 (f1, f2, dt) values ('mik1', @IncidentID, getdate()) 

       IF UPDATE(ref_status) OR UPDATE(ref_operatorgroup) --basically if an incident has had its status changed then....
       BEGIN
              --insert into mik1 (f1, dt) values ('mik2', getdate()) 
            DECLARE @ContractID UNIQUEIDENTIFIER, @UnitBased INT, @AfterUnits float, @BeforeUnits float,  @Operator_Group varchar(MAX), @Changer UNIQUEIDENTIFIER, @ContractTeamUser int;
              DECLARE @ref_status NVARCHAR(100);
              DECLARE @new_operator_group VARCHAR(MAX);
              DECLARE @new_operator_group_id UNIQUEIDENTIFIER;
              DECLARE @before_status NVARCHAR(100);
              DECLARE @actie2 VARCHAR(MAX);

              SELECT @actie2 = actie FROM incident WHERE unid = @IncidentID
              SELECT @BeforeUnits = vrijegetal1, @ContractID = ref_dnocontractid, @Changer = UPPER(uidwijzig), @Operator_Group = ref_operatorgroup, @ref_status = ref_status FROM inserted; --find out which contract this incident was closed with
              SELECT @before_status = ref_status FROM deleted;
              --insert into mik1 (f1, dt) values ('mik3', getdate()) 
               -- C1605-0051
              IF @ref_status = 'Internal (DO NOT USE)' AND @before_status = 'Completed'
              BEGIN


                     --SELECT @new_operator_group_id = unid from dbo.actiedoor where naam = @Operator_Group
                     --SET @new_operator_group = @Operator_Group
                     
                     ----For testing with Internal Systems
                     ----IF SUBSTRING(@Operator_Group, 2, 2) = 'nt'
                     ----BEGIN
                     ----   SELECT @new_operator_group_id = unid from dbo.actiedoor where naam = 'CAB Board'
                     ----   SET @new_operator_group = 'CAB Board'
                     ----END
                     
                     --IF SUBSTRING(@Operator_Group, 2, 2) = 'FS'
                     --BEGIN
                     --     SELECT @new_operator_group_id = unid from dbo.actiedoor where naam = '~FS-2nd'
                     --     SET @new_operator_group = '~FS-2nd'
                     --END

                     --IF SUBSTRING(@Operator_Group, 2, 2) = 'RS'
                     --BEGIN
                     --     SELECT @new_operator_group_id = unid from dbo.actiedoor where naam = '~RS-1st'
                     --     SET @new_operator_group = '~RS-1st'
                     --END

                     --IF SUBSTRING(@Operator_Group, 2, 2) = 'IM'
                     --BEGIN
                     --     SELECT @new_operator_group_id = unid from dbo.actiedoor where naam = '~IM-1st'
                     --     SET @new_operator_group = '~IM-1st'
                     --END

                     --UPDATE dbo.incident      SET operatorgroupid = @new_operator_group_id, ref_operatorgroup = @new_operator_group WHERE dbo.incident.unid = @IncidentID;
                     
                     -- Logic in here for exclusions eg; Tesseract, auto replies etc.

                     DECLARE @ignore INT;

                     -- if there is tesseract or auto reply etc in first 400 characters, ignore
                     SET @ignore = 0;
                     IF CHARINDEX('Tesseract Confirmation', SUBSTRING(@actie2, 1, 400), 1) > 0
                     BEGIN
                           SET @ignore = 1;
                     END

                     IF @ignore = 0
                     BEGIN
                           UPDATE dbo.incident  SET vrijelogisch5 = 1 WHERE dbo.incident.unid = @IncidentID;
                     END
              END
              -- C1605-0051

              IF @ContractID IS NOT NULL --if a contract was referenced then...
              BEGIN
                           SET @UnitBased = 0; --used to say if the referenced contract is a unit based on (based on its category)

                           --determine if this is unit based contract being referenced
                           SELECT  @UnitBased = count(*)
                           FROM dbo.dnocontract 
                           WHERE dbo.dnocontract.categorieid IN ('028CDC56-1058-4FBC-8CF3-39A7721B5342') --Respond contracts only
                           AND dbo.dnocontract.unid = @ContractID;


                           IF @UnitBased > 0 --if this is a unit based contract then....
                           BEGIN

                                  --find out if changer is in the contract admin team....
                                  SELECT  @ContractTeamUser =    count(*) 
                                  FROM    dbo.actiedoorlink INNER JOIN
                                         dbo.actiedoor ON dbo.actiedoorlink.actiedoorid = dbo.actiedoor.unid INNER JOIN
                                         dbo.actiedoor AS actiedoor_1 ON dbo.actiedoorlink.actiedoorgroepid = actiedoor_1.unid
                                  where upper(dbo.actiedoor.loginnaamtopdeskid) =  @Changer
                                         AND actiedoor_1.naam = 'Contract Admin' 

                                  --find out if changer is the workflow chanigng calls to closed etc as we don't want to reset UNITS burned all back to 0.....
                                  IF @Changer = '28961B36-1E06-4E94-A62B-CA64A20DD72D'
                                         BEGIN
                                                Set @ContractTeamUser = 1
                                  END


                                  --if they are NOT in Contract Team then we need to calculate some units...
                                  IF isnull(@ContractTeamUser,0) = 0
                                  BEGIN
                                         --SET @AfterUnits = @BeforeUnits
                                         SELECT @AfterUnits = 
                                         CASE 
                                                WHEN   @Operator_Group IN ('~RS-1st','~FS-1st','~RS-2nd','~FS-2nd','~RS-3rd','~FS-3rd','~RS-Oracle')
                                                       THEN 1
                                                WHEN   @Operator_Group IN ('~FS-Engineers1','~FS-Engineers2','~FS-Engineers3','~FS-Engineers4','~FS-Engineers5','~FS-Engineers6')
                                                       THEN 1
                                                ELSE  0
                                         END

                                         --update the incident with the correct number of units.
                                         UPDATE dbo.incident
                                         SET vrijegetal1 = isnull(@AfterUnits,0)  --- write the total units burned for all incidents for this contract to the contract
                                         WHERE dbo.incident.unid = @IncidentID;

                                  END
                                  --if they ARE in the contract admin team then don't do anything to units. Trust that they are typing in the right numbers.

                                         ----useful for testing any errors....
                                         --insert into _EsteemTesting
                                         --(TestUNID,TestInt) values (@Changer,@ContractTeamUser);
                           END
              END
       END


       IF UPDATE(vrijelogisch1) OR UPDATE(vrijelogisch2) OR UPDATE(vrijedatum1) OR UPDATE(vrijegetal2) --SLA Breached fields have been changed or date responded has changed
                     BEGIN
                           DECLARE @ChangedBy UNIQUEIDENTIFIER,  @OriginalRespondSLA bit, @OriginalResolveSLA bit, @OriginalRespondDate datetime, @OriginalEscalation float
                           SELECT @ChangedBy = uidwijzig  FROM inserted
                           SELECT @OriginalRespondSLA = vrijelogisch1, @OriginalResolveSLA = vrijelogisch2, @OriginalRespondDate = vrijedatum1, @OriginalEscalation = vrijegetal2 FROM deleted 
                           IF upper(@ChangedBy) <> '28961B36-1E06-4E94-A62B-CA64A20DD72D'--NOT edited by HTTP_Admin then do nothing
                                  BEGIN

                                         IF TRIGGER_NESTLEVEL() > 1
                                                RETURN

                                         UPDATE dbo.incident
                                         SET vrijelogisch1 = @OriginalRespondSLA,   --- write the original SLA data back in.
                                         vrijelogisch2 = @OriginalResolveSLA,
                                         vrijedatum1 = @OriginalRespondDate,
                                         vrijegetal2 = @OriginalEscalation
                                         WHERE dbo.incident.unid = @IncidentID;
                           END
                     END



       If UPDATE(aanmeldervestigingid) --site has changed (recaculate the white label field)......
       BEGIN
       --START of code.....

       DECLARE @SITEID UNIQUEIDENTIFIER
       SET  @SITEID = (select aanmeldervestigingid from incident where unid = @IncidentID)
       DECLARE @WhiteLabelSite varchar(max)

       --get the White Label value (naam) from the Site, whether or not it is a head office....
       SET  @WhiteLabelSite = (
       SELECT       dbo.extrab.naam AS WhiteLabel
       FROM            dbo.vestiging INNER JOIN dbo.extrab ON dbo.vestiging.extrabid = dbo.extrab.unid
       WHERE        (dbo.vestiging.unid = @SITEID) AND (dbo.vestiging.oudervestigingid IS NULL)
       UNION all
       --need to get the white lable from a subsite....
       SELECT       dbo.extrab.naam AS WhiteLabel
       FROM            dbo.vestiging INNER JOIN dbo.vestiging AS vestiging_1 ON dbo.vestiging.oudervestigingid = vestiging_1.unid INNER JOIN dbo.extrab ON vestiging_1.extrabid = dbo.extrab.unid
       WHERE        (dbo.vestiging.unid = @SITEID) AND (dbo.vestiging.oudervestigingid IS NOT NULL))

       DECLARE @WhiteLabelIncident UNIQUEIDENTIFIER
       --get the right unid for the "White Lable Group" field where the naam needs to match the "White Label" naam field on the Site.....
       SET @WhiteLabelIncident = (SELECT TOP(1) unid FROM afdeling WHERE naam = @WhiteLabelSite)

       --on the new incident we need to set the "White Label Group" Field so that it has the right value.
                     UPDATE       incident
                     SET                aanmelderafdelingid = @WhiteLabelIncident
                     WHERE        (UNID = @IncidentID)

       END

       -- Satellite
       DECLARE @korteomschrijving2 nvarchar(80)
       DECLARE @vrijetekst4 nvarchar(100)
       DECLARE @vrijetekst4_cmp nvarchar(100)
       DECLARE @actie nvarchar(max)
       DECLARE @start int
       DECLARE @space int

       SET  @vrijetekst4_cmp = (select vrijetekst4 from incident where unid = @IncidentID)

       IF @vrijetekst4_cmp IS NULL OR @vrijetekst4_cmp = ''
       BEGIN
              SET  @actie = (select actie from incident where unid = @IncidentID)
              
              --ESTEEMMASTERREF:I1604-11395 

              SET @start = CHARINDEX('ESTEEMMASTERREF:', @actie, 1)
              SET @space = CHARINDEX(CHAR(32), @actie, @start)

              IF @start > 0
              BEGIN
                     SET @vrijetekst4 = SUBSTRING(@actie, (@start + 16), 13) --(@space - (@start - 16)))

                     UPDATE incident
                     SET vrijetekst4 = @vrijetekst4 -- + ' space ' + convert(varchar(10), @space)  + ' start ' + convert(varchar(10), @start)
                     WHERE (UNID = @IncidentID)
              END
       END
       -- Satellite

       -- Time registration
       --
       -- TEST                                  NAME                       LIVE
       -- ----                                  ----                       ----
       -- attvrijegetal1          FSR Number
       -- attvrijegetal2          Travel Time
       -- attvrijedatum1          Arrival Date
       -- attvrijedatum2          Finish Date
       -- attvrijetekst3          Engineer Initials

       --IF UPDATE(attvrijedatum1)
       --BEGIN
       --     DECLARE @id UNIQUEIDENTIFIER
       --     DECLARE @reason UNIQUEIDENTIFIER
       --     DECLARE @dt DATETIME
       --     DECLARE @op UNIQUEIDENTIFIER
       --     DECLARE @fsr FLOAT
       --     DECLARE @travel FLOAT
       --     DECLARE @arrival DATETIME
       --     DECLARE @departure DATETIME
       --     DECLARE @engineer VARCHAR(100)
       --     DECLARE @op2 VARCHAR(100)
       --     DECLARE @op3 UNIQUEIDENTIFIER
       --     DECLARE @status VARCHAR(100)
       --     DECLARE @level SMALLINT
       --     DECLARE @lijn1tijdbesteed INT
       --     DECLARE @tijdbesteed INT
       --     DECLARE @naam VARCHAR(30)

       --     SET @dt = GETDATE()

       --     SELECT @op = uidwijzig,
       --     @fsr = attvrijegetal1,
       --     @travel = attvrijegetal2, 
       --     @arrival = attvrijedatum1, 
       --     @departure = attvrijedatum2, 
       --     @engineer = attvrijetekst3,
       --     @status = ref_status,
       --     @naam = naam
       --     FROM incident
       --     WHERE unid = @IncidentID

       --     INSERT INTO est_time_registration
       --     (
       --     dated,
       --     incident,
       --     status,
       --     engineer,
       --     arrival,
       --     departure,
       --     travel,
       --     onsite,
       --     fsr
       --     )
       --     VALUES
       --     (
       --     @dt,
       --     @naam,
       --     @status,
       --     @engineer,
       --     @arrival,
       --     @departure,
       --     @travel,
       --     DATEDIFF(MI, @arrival, @departure),
       --     @fsr
       --     )

       --     IF @status = 'Logged'
       --     BEGIN
       --            SET @lijn1tijdbesteed = DATEDIFF(MI, @arrival, @departure) + 2 + @travel
       --            SET @tijdbesteed = 0 
       --            SET @level = 1
       --     END
       --     ELSE
       --     BEGIN
       --            SET @level = 2
       --            SET @tijdbesteed = DATEDIFF(MI, @arrival, @departure) + 2 + @travel
       --            SET @lijn1tijdbesteed = 0
       --     END

       --     --SELECT @op2 = naam
       --     --FROM gebruiker 
       --     --WHERE unid = @op

       --     --SELECT @op3 = unid
       --     --FROM actiedoor
       --     --WHERE ref_dynanaam = @op2 

       --     -- Change to Workflow as we need to identify application updates
       --     SELECT @op = unid
       --     FROM gebruiker 
       --     WHERE naam = '- Workflow'

       --     SELECT @op3 = unid
       --     FROM actiedoor
       --     WHERE ref_dynanaam = '- Workflow' 
              
       --     SELECT @reason = unid 
       --     FROM time_registration_reason
       --     WHERE naam = 'Engineer Arrival Time'

       --     SET @id = NEWID()

       --     INSERT INTO time_registration_incident
       --     (
       --     unid, 
       --     timetaken, 
       --     entrydate, 
       --     operatorid, 
       --     operatorgroupid, 
       --     status, 
       --     datwijzig, 
       --     dataanmk, 
       --     uidaanmk,
       --     uidwijzig, 
       --     cardid, 
       --     reason,
       --     notes
       --     )
       --     VALUES
       --     (
       --     @id, 
       --     1, 
       --     @dt,
       --     @op3,
       --     @op3,
       --     @level,
       --     @dt,
       --     @dt,
       --     @op,
       --     @op,
       --     @IncidentID, 
       --     @reason,
       --     ' | ' + @engineer + ' | ' + STR(@fsr) + ' | ' + CONVERT(VARCHAR(20), @arrival) + ' | '
       --     )

       --     SELECT @reason = unid 
       --     FROM time_registration_reason
       --     WHERE naam = 'Engineer Departure Time'

       --     SET @id = NEWID()

       --     INSERT INTO time_registration_incident
       --     (
       --     unid, 
       --     timetaken, 
       --     entrydate, 
       --     operatorid, 
       --     operatorgroupid, 
       --     status, 
       --     datwijzig, 
       --     dataanmk, 
       --     uidaanmk,
       --     uidwijzig,  
       --     cardid, 
       --     reason,
       --     notes
       --     )
       --     VALUES
       --     (
       --     @id, 
       --     1, 
       --     @dt,
       --     @op3,
       --     @op3,
       --     @level,
       --     @dt,
       --     @dt,
       --     @op,
       --     @op,
       --     @IncidentID, 
       --     @reason,
       --     ' | ' + @engineer + ' | ' + STR(@fsr) + ' | ' + CONVERT(VARCHAR(20), @departure) + ' | '
       --     )

       --     SELECT @reason = unid 
       --     FROM time_registration_reason
       --     WHERE naam = 'Engineer On Site Time'

       --     SET @id = NEWID()

       --     INSERT INTO time_registration_incident
       --     (
       --     unid, 
       --     timetaken, 
       --     entrydate, 
       --     operatorid, 
       --     operatorgroupid, 
       --     status, 
       --     datwijzig, 
       --     dataanmk, 
       --     uidaanmk,
       --     uidwijzig,  
       --     cardid, 
       --     reason,
       --     notes
       --     )
       --     VALUES
       --     (
       --     @id, 
       --     DATEDIFF(MI, @arrival, @departure), 
       --     @dt,
       --     @op3,
       --     @op3,
       --     @level,
       --     @dt,
       --     @dt,
       --     @op,
       --     @op,
       --     @IncidentID, 
       --     @reason,
       --     ' | ' + @engineer + ' | ' + STR(@fsr) + ' | ' + CONVERT(VARCHAR(20), @arrival) + ' to ' + CONVERT(VARCHAR(20), @departure) + ' | '
       --     )

       --     SELECT @reason = unid 
       --     FROM time_registration_reason
       --     WHERE naam = 'Engineer Travel Time'

       --     SET @id = NEWID()

       --     INSERT INTO time_registration_incident
       --     (
       --     unid, 
       --     timetaken, 
       --     entrydate, 
       --     operatorid, 
       --     operatorgroupid, 
       --     status, 
       --     datwijzig, 
       --     dataanmk, 
       --     uidaanmk,
       --     uidwijzig,  
       --     cardid, 
       --     reason,
       --     notes
       --     )
       --     VALUES
       --     (
       --     @id, 
       --     @travel, 
       --     @dt,
       --     @op3,
       --     @op3,
       --     @level,
       --     @dt,
       --     @dt,
       --     @op,
       --     @op,
       --     @IncidentID, 
       --     @reason,
       --     ' | ' + @engineer + ' | ' + STR(@fsr) + ' | '
       --     )
                     
       --     UPDATE incident 
       --     SET attvrijedatum1 = NULL,
       --     attvrijedatum2 = NULL,
       --     attvrijegetal1 = '',
       --     attvrijegetal2 = '',
       --     attvrijetekst3 = '',
       --     totaletijd = totaletijd + DATEDIFF(MI, @arrival, @departure) + 2 + @travel,
       --     lijn1tijdbesteed = lijn1tijdbesteed + @lijn1tijdbesteed,
       --     tijdbesteed = tijdbesteed + @tijdbesteed
       --     WHERE unid = @IncidentID
       --END
       -- Time registration

       DECLARE @vrijelogisch3 SMALLINT
       DECLARE @vrijelogisch4 SMALLINT
       DECLARE @uidwijzig UNIQUEIDENTIFIER
       DECLARE @user VARCHAR(109)
       
       --IF UPDATE(vrijelogisch3) 
       --BEGIN
       --     SELECT @uidwijzig = uidwijzig, @vrijelogisch3 = vrijelogisch3
       --     FROM incident
       --     where unid = @IncidentID

       --     SELECT @user = naam
       --     FROM gebruiker
       --     WHERE unid = @uidwijzig

       --     INSERT INTO sat_audit
       --     (dated, userid, field)
       --     VALUES
       --     (getdate(), @user, 'DO NOT USE')

       --END

       --IF UPDATE(vrijelogisch4)
       --BEGIN
       --     SELECT @uidwijzig = uidwijzig, @vrijelogisch4 = vrijelogisch4
       --     FROM incident
       --     where unid = @IncidentID

       --     SELECT @user = naam
       --     FROM gebruiker
       --     WHERE unid = @uidwijzig

       --     INSERT INTO sat_audit
       --     (dated, userid, field)
       --     VALUES
       --     (getdate(), @user, 'Survey')
       --END

END









GO

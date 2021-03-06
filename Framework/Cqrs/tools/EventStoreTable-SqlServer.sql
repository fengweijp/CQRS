﻿SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EventStore](
	[EventId] [uniqueidentifier] NOT NULL,
	[Data] [text] NOT NULL,
	[EventType] [nvarchar](MAX) NOT NULL,
	[AggregateId] [nvarchar](445) NOT NULL,
	[AggregateRsn] [uniqueidentifier] NOT NULL,
	[Version] [bigint] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[CorrelationId] [uniqueidentifier] NOT NULL,
	CONSTRAINT [PK_EventStore] PRIMARY KEY NONCLUSTERED 
	(
		[EventId] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
	CONSTRAINT [UIX_AggregateId_Version] UNIQUE NONCLUSTERED 
	(
		[AggregateId] ASC,
		[Version] DESC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

CREATE PARTITION FUNCTION PF_EventStore_AggregateRsn (uniqueidentifier)
AS RANGE RIGHT
FOR VALUES
(
   N'00000000-0000-0000-0000-0D0000000000', 
   N'00000000-0000-0000-0000-1A0000000000', 
   N'00000000-0000-0000-0000-270000000000', 
   N'00000000-0000-0000-0000-340000000000', 
   N'00000000-0000-0000-0000-410000000000', 
   N'00000000-0000-0000-0000-4E0000000000', 
   N'00000000-0000-0000-0000-5B0000000000', 
   N'00000000-0000-0000-0000-680000000000', 
   N'00000000-0000-0000-0000-750000000000', 
   N'00000000-0000-0000-0000-820000000000', 
   N'00000000-0000-0000-0000-8F0000000000', 
   N'00000000-0000-0000-0000-9C0000000000', 
   N'00000000-0000-0000-0000-A90000000000', 
   N'00000000-0000-0000-0000-B60000000000', 
   N'00000000-0000-0000-0000-C30000000000', 
   N'00000000-0000-0000-0000-D00000000000', 
   N'00000000-0000-0000-0000-DD0000000000', 
   N'00000000-0000-0000-0000-EA0000000000', 
   N'00000000-0000-0000-0000-F70000000000' 
) ;
GO

CREATE PARTITION SCHEME PS_EventStore_AggregateRsn
AS PARTITION PF_EventStore_AggregateRsn ALL TO ([PRIMARY]) 
GO

CREATE CLUSTERED INDEX [IX_AggregateRsn] ON [dbo].[EventStore]
(
	[AggregateRsn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON PS_EventStore_AggregateRsn(AggregateRsn)
GO

CREATE NONCLUSTERED INDEX [IX_EventId] ON [dbo].[EventStore]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_CorrelationId] ON [dbo].[EventStore]
(
	[CorrelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Timestamp] ON [dbo].[EventStore]
(
	[Timestamp] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [IX_Timestamp_EventId_CorrelationId] ON [dbo].[EventStore]
(
	[Timestamp] DESC,
	[EventId] ASC,
	[CorrelationId] ASC
)
INCLUDE ([EventType]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO

CREATE STATISTICS [ST_CorrelationId_Timestamp] ON [dbo].[EventStore]([CorrelationId], [Timestamp])
GO

CREATE STATISTICS [ST_EventId_CorrelationId_Timestamp] ON [dbo].[EventStore]([EventId], [CorrelationId], [Timestamp])
GO

SELECT ps.name,pf.name,boundary_id,value
, ps.*
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON pf.function_id=ps.function_id
INNER JOIN sys.partition_range_values prf ON pf.function_id=prf.function_id

SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name = 'EventStore'
﻿#region Copyright
// // -----------------------------------------------------------------------
// // <copyright company="cdmdotnet Limited">
// // 	Copyright cdmdotnet Limited. All rights reserved.
// // </copyright>
// // -----------------------------------------------------------------------
#endregion

using System;
using System.Linq.Expressions;
using Cqrs.MongoDB.DataStores.Indexes;

namespace Cqrs.MongoDB.Events.Indexes
{
	public class ByAggregateIdAndVersionMongoDbIndex : MongoDbIndex<MongoDbEventData>
	{
		public ByAggregateIdAndVersionMongoDbIndex()
		{
			Selectors = new Expression<Func<MongoDbEventData, object>>[]
			{
				entity => entity.AggregateId,
				entity => entity.Version
			};

			IsUnique = true;
		}
	}
}
﻿#region Copyright
// // -----------------------------------------------------------------------
// // <copyright company="cdmdotnet Limited">
// // 	Copyright cdmdotnet Limited. All rights reserved.
// // </copyright>
// // -----------------------------------------------------------------------
#endregion

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using Cqrs.Domain.Exceptions;
using Cqrs.Events;
using Cqrs.Infrastructure;

namespace Cqrs.Domain
{
	public abstract class AggregateRoot<TAuthenticationToken> : IAggregateRoot<TAuthenticationToken>
	{
		private ReaderWriterLockSlim Lock { get; set; }

		private ICollection<IEvent<TAuthenticationToken>> Changes { get; set; }

		public Guid Id { get; protected set; }

		public int Version { get; protected set; }

		protected AggregateRoot()
		{
			Lock = new ReaderWriterLockSlim();
			Changes = new ReadOnlyCollection<IEvent<TAuthenticationToken>>(new List<IEvent<TAuthenticationToken>>());
		}

		public IEnumerable<IEvent<TAuthenticationToken>> GetUncommittedChanges()
		{
			return Changes;
		}

		public virtual void MarkChangesAsCommitted()
		{
			Lock.EnterWriteLock();
			try
			{
				Version = Version + Changes.Count;
				Changes = new ReadOnlyCollection<IEvent<TAuthenticationToken>>(new List<IEvent<TAuthenticationToken>>());
			}
			finally
			{
				Lock.ExitWriteLock();
			}
		}

		public virtual void LoadFromHistory(IEnumerable<IEvent<TAuthenticationToken>> history)
		{
			Type aggregateType = GetType();
			foreach (IEvent<TAuthenticationToken> @event in history.OrderBy(e => e.Version))
			{
				if (@event.Version != Version + 1)
					throw new EventsOutOfOrderException(@event.Id, aggregateType, Version + 1, @event.Version);
				ApplyChange(@event, true);
			}
		}

		protected virtual void ApplyChange(IEvent<TAuthenticationToken> @event)
		{
			ApplyChange(@event, false);
		}

		private void ApplyChange(IEvent<TAuthenticationToken> @event, bool isEventReplay)
		{
			Lock.EnterWriteLock();
			try
			{
				this.AsDynamic().Apply(@event);
				if (!isEventReplay)
				{
					Changes = new ReadOnlyCollection<IEvent<TAuthenticationToken>>(new []{@event}.Concat(Changes).ToList());
				}
				else
				{
					Id = @event.Id;
					Version++;
				}
			}
			finally
			{
				Lock.ExitWriteLock();
			}
		}
	}
}
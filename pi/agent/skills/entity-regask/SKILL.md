---
name: entity-regask
description: Skill for creating and managing repositories in NestJS with MongoDB, following best practices and
---


## Steps
1. Define entity in cores/entities with Mongoose schema and TypeScript interface
2. Create repository in cores/repositories that extends base repository and injects Mongoose model
3. Register repository in RepositoriesModule with MongooseModule.forFeature
4. Some repositories may extend BaseSoftDeleteRepositoryAbstract for soft delete functionality (need to confirm when to use soft delete vs hard delete)
5. Some repositories having special incremental logic so need to follow the pattern around the context

# Creating NestJS Repositories

## Repository Structure

Every repository must:
1. Extend `BaseRepositoryAbstract<Entity>`
2. Use `@Injectable()` decorator
3. Inject the Mongoose model with `@InjectDefaultModel`
4. Inject `ClsService` for context management

### Basic Repository Template

```typescript
import { Injectable } from '@nestjs/common';
import { BaseRepositoryAbstract } from '@regask/common-lib/mongo/base.repository';
import { Document, Model } from 'mongoose';
import { ClsService } from 'nestjs-cls';

import { MyEntity } from '@/cores/entities/my-entity/entity';
import { InjectDefaultModel } from '@/infra/database/inject-default-model.decorator';

@Injectable()
export class MyRepository extends BaseRepositoryAbstract<MyEntity> {
  constructor(
    @InjectDefaultModel(MyEntity.name)
    entity: Model<Document<MyEntity>>,
    private cls: ClsService,
  ) {
    super(entity);
  }
}
```

### Soft Delete Repository Template

For entities that extend `BaseSoftDeleteEntity`, use `BaseSoftDeleteRepositoryAbstract`:

```typescript
import { Injectable } from '@nestjs/common';
import { BaseSoftDeleteRepositoryAbstract } from '@regask/common-lib/mongo/base-soft-delete.repository';
import { Document } from 'mongoose';
import { SoftDeleteModel } from 'mongoose-delete';
import { ClsService } from 'nestjs-cls';

import { MyEntity } from '@/cores/entities/my-entity/entity';
import { InjectDefaultModel } from '@/infra/database/inject-default-model.decorator';

@Injectable()
export class MyRepository extends BaseSoftDeleteRepositoryAbstract<MyEntity> {
  constructor(
    @InjectDefaultModel(MyEntity.name)
    entity: SoftDeleteModel<Document<MyEntity>>,
    protected cls: ClsService,
  ) {
    super(entity, cls);
  }
}
```

Key differences from regular repository:
- Extends `BaseSoftDeleteRepositoryAbstract` instead of `BaseRepositoryAbstract`
- Uses `SoftDeleteModel<Document<MyEntity>>` instead of `Model<Document<MyEntity>>`
- Passes `cls` to super constructor for audit trail (deletedBy)

## Directory Structure

```
src/cores/
├── entities/
│   └── my-entity/
│       ├── entity.ts
│       └── enums.ts
├── repositories/
│   └── my-entity/
│       ├── repository.ts
│       └── query-builders/           (Optional)
│           └── get-details.query-builder.ts
└── repositories.module.ts
```

## Common Repository Methods

### findOneByCondition

Find a single document by query conditions:

```typescript
const entity = await this.myRepository.findOneByCondition({
  condition: {
    _id: input.id,
    companyId: input.companyId,
  },
});

if (!entity) {
  throw new NotFoundException('entity_not_found').withErrorCode('ENTITY_NOT_FOUND');
}
```

### findOneAndUpdate

Atomic find and update operation:

```typescript
const updatedEntity = await this.myRepository.findOneAndUpdate(
  // Query condition
  {
    _id: input.id,
    status: StatusEnum.Pending,
  },
  // Update data
  {
    status: StatusEnum.Approved,
    review: {
      reviewer: {
        id: input.reviewer.userId,
        name: `${input.reviewer.firstName} ${input.reviewer.lastName}`,
      },
      reviewedAt: new Date(),
      action: ReviewActionEnum.Approve,
      remarks: input.remarks,
    },
  },
);
```

### aggregateWithSearch

Advanced MongoDB aggregation with Atlas Search:

```typescript
// Get count
const countResult = await this.myRepository.aggregateWithSearch({
  search: this.#buildSearchPipelineForCount(searchFilter) as any,
  pipeline: [
    {
      $project: {
        searchMeta: '$$SEARCH_META',
      },
    },
    {
      $limit: 1,
    },
  ],
});

const total = countResult[0]?.searchMeta?.count?.total ?? 0;

// Get paginated results
const items = await this.myRepository.aggregateWithSearch<MyEntity>({
  search: this.#buildSearchPipeline(searchFilter, sortConfig) as any,
  pipeline: [
    ...this.#skipPipeline(input),
    ...this.#limitPipeline(input),
    ...this.#lookupOriginalDocuments(),
  ],
});
```

### collectionName Property

Access the MongoDB collection name:

```typescript
const lookup = {
  $lookup: {
    from: this.myRepository.collectionName,
    localField: '_id',
    foreignField: '_id',
    as: 'originalDocument',
  },
};
```

### findOneById

Find by MongoDB ObjectId:

```typescript
const entity = await this.myRepository.findOneById(`${entityId}`);
```

## Soft Delete Repository Methods

These methods are available when extending `BaseSoftDeleteRepositoryAbstract`:

### delete (Soft Delete)

The `delete` method performs soft delete instead of hard delete:

```typescript
// Marks record as deleted, sets deletedAt and deletedBy
await this.myRepository.delete(entityId);
```

Behind the scenes:
- Sets `deleted: true`
- Sets `deletedAt: new Date()`
- Sets `deletedBy: auditUser.userId` (from CLS context)

### deleteMany

Soft delete multiple records:

```typescript
await this.myRepository.deleteMany({
  companyId: input.companyId,
  status: StatusEnum.Archived,
});
```

### findAllWithDeleted

Find records including soft-deleted ones:

```typescript
// Include soft-deleted records in results
const allRecords = await this.myRepository.findAllWithDeleted(
  { companyId: input.companyId },
  { projection: { displayId: 1, status: 1, deleted: 1 } },
);
```

### restore

Restore soft-deleted records:

```typescript
// Restore specific records
await this.model.restore({
  _id: { $in: idsToRestore },
});
```

### Custom Methods with Soft Delete

```typescript
@Injectable()
export class MyRepository extends BaseSoftDeleteRepositoryAbstract<MyEntity> {
  // Find with optional inclusion of deleted records
  async findAllByCompany({
    companyId,
    projection = {},
    withDeleted = false,
  }: {
    companyId: string;
    projection?: Record<string, 1 | 0>;
    withDeleted?: boolean;
  }): Promise<MyEntity[]> {
    const conditions = { companyId };

    if (withDeleted) {
      return await this.findAllWithDeleted(conditions, { projection });
    } else {
      return await this.findAll(conditions, { projection });
    }
  }

  // Restore records by condition
  async restoreByIds(ids: string[]) {
    await this.model.restore({
      _id: { $in: ids },
    });
  }
}
```

### aggregateWithSearch (Soft Delete)

The soft delete repository automatically excludes deleted records in Atlas Search:

```typescript
// Deleted records are automatically filtered out
const items = await this.myRepository.aggregateWithSearch<MyEntity>({
  search: searchPipeline,
  pipeline: aggregationPipeline,
});
```

The base class adds this filter automatically:
```typescript
{
  operator: AtlasSearchFilterOperator.NotEqual,
  attribute: 'deleted',
  value: true,
}
```

## Repository Registration

### RepositoriesModule

Register all repositories in a global module:

```typescript
import { Global, Module } from '@nestjs/common';

import { CONNECTION_NAME } from '@/infra/database/constant';
import { getMongooseModule } from '@/infra/database/mongo/helpers';

import { MyEntity } from './entities/my-entity/entity';
import { AnotherEntity } from './entities/another-entity/entity';
import { MyRepository } from './repositories/my-entity/repository';
import { AnotherRepository } from './repositories/another-entity/repository';
import { MyQueryBuilder } from './repositories/my-entity/query-builders/get-details.query-builder';

@Global()
@Module({
  imports: [
    getMongooseModule(CONNECTION_NAME, MyEntity),
    getMongooseModule(CONNECTION_NAME, AnotherEntity),
  ],
  controllers: [],
  providers: [
    MyRepository,
    MyQueryBuilder,
    AnotherRepository,
  ],
  exports: [
    MyRepository,
    MyQueryBuilder,
    AnotherRepository,
  ],
})
export class RepositoriesModule {}
```

Key features:
- `@Global()` makes repositories available application-wide
- `getMongooseModule` sets up Mongoose schemas with connection
- Export all repositories and query builders for injection

## Query Builder Pattern

For complex aggregation pipelines, use query builders:

```typescript
import { Injectable } from '@nestjs/common';

@Injectable()
export class MyQueryBuilder {
  execute() {
    return [
      {
        $project: {
          password: 0,                    // Exclude sensitive fields
          resetPasswordToken: 0,
          internalNotes: 0,
        },
      },
    ];
  }
}
```

Usage in usecase:

```typescript
@Injectable()
export class GetDetailsUseCase extends BaseUseCase<Input, Output> {
  constructor(
    private myRepository: MyRepository,
    private myQueryBuilder: MyQueryBuilder,
  ) {
    super();
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    const pipeline = this.myQueryBuilder.execute();
    const result = await this.myRepository.aggregate(pipeline);
    // ...
  }
}
```

## Using Repositories in Usecases

### Pattern 1: Simple Find

```typescript
@Injectable()
export class GetDetailsUseCase extends BaseUseCase<Input, Output> {
  constructor(private myRepository: MyRepository) {
    super();
    this.logger = new Logger(GetDetailsUseCase.name);
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    const entity = await this.myRepository.findOneByCondition({
      condition: {
        _id: input.id,
        companyId: input.companyId,
      },
    });

    if (!entity) {
      throw new NotFoundException('entity_not_found').withErrorCode(
        'ENTITY_NOT_FOUND',
      );
    }

    return this.success(entity);
  }
}
```

### Pattern 2: Find and Update

```typescript
@Injectable()
export class ApproveUseCase extends BaseUseCase<Input, Output> {
  constructor(private myRepository: MyRepository) {
    super();
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    // Guard check
    const entity = await this.myRepository.findOneByCondition({
      condition: {
        _id: input.id,
        companyId: input.reviewer.userCompany,
      },
    });

    if (!entity) {
      throw new NotFoundException('entity_not_found');
    }

    if (entity.status !== StatusEnum.Pending) {
      throw new BusinessRuleException('entity_not_pending');
    }

    // Atomic update
    const updatedEntity = await this.myRepository.findOneAndUpdate(
      {
        _id: input.id,
        status: StatusEnum.Pending,
      },
      {
        status: StatusEnum.Approved,
        review: {
          reviewer: {
            id: input.reviewer.userId,
            name: `${input.reviewer.firstName} ${input.reviewer.lastName}`,
          },
          reviewedAt: new Date(),
          action: ReviewActionEnum.Approve,
        },
      },
    );

    return { data: updatedEntity, error: null };
  }
}
```

### Pattern 3: Advanced Search with Aggregation

```typescript
@Injectable()
export class FetchDataGridUseCase extends BaseUseCase<Input, Output> {
  constructor(
    private myRepository: MyRepository,
    private filterConcern: MapFilterConcern,
  ) {
    super();
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    const searchFilter = this.#buildSearchFilter(input);

    // Parallel count and fetch
    const [total, items] = await Promise.all([
      this.#getFilteredRecordCount(searchFilter),
      this.#executeSearchQuery(input, searchFilter),
    ]);

    return {
      error: null,
      data: { total, items },
    };
  }

  async #getFilteredRecordCount(searchFilter: SearchOperatorQueryType): Promise<number> {
    const countResult = await this.myRepository.aggregateWithSearch({
      search: this.#buildSearchPipelineForCount(searchFilter) as any,
      pipeline: [
        { $project: { searchMeta: '$$SEARCH_META' } },
        { $limit: 1 },
      ],
    });

    return countResult[0]?.searchMeta?.count?.total ?? 0;
  }

  async #executeSearchQuery(
    input: Input,
    searchFilter: SearchOperatorQueryType,
  ): Promise<MyEntity[]> {
    return await this.myRepository.aggregateWithSearch<MyEntity>({
      search: this.#buildSearchPipeline(searchFilter) as any,
      pipeline: [
        ...this.#skipPipeline(input),
        ...this.#limitPipeline(input),
        ...this.#lookupOriginalDocuments(),
      ],
    });
  }

  #lookupOriginalDocuments(): PipelineStage[] {
    return [
      {
        $lookup: {
          from: this.myRepository.collectionName,
          localField: '_id',
          foreignField: '_id',
          as: 'originalDocument',
        },
      },
      { $unwind: '$originalDocument' },
      { $replaceRoot: { newRoot: '$originalDocument' } },
    ];
  }
}
```

## Testing Repositories

Repositories are tested through integration tests with usecases:

```typescript
describe('@workflows/my-workflow/usecase', () => {
  const testHelper = new CustomTestHelper(CONNECTION_NAME, AppModule);

  beforeAll(async () => {
    await testHelper.beforeAll();
  });

  afterAll(() => testHelper.afterAll());
  afterEach(() => testHelper.cleanUp());

  describe('#handle', () => {
    it('should find and return entity', async () => {
      // Create test data using factory
      const entity = await testHelper
        .factoryBuilder(MyEntityFactory)
        .create({
          companyId,
          status: StatusEnum.Pending,
        });

      // Execute usecase (which uses repository)
      const { error, data } = await testHelper
        .get(GetDetailsUseCase)
        .execute({
          id: entity._id.toString(),
          companyId: entity.companyId,
        });

      expect(error).toBeNull();
      expect(data._id.toString()).toBe(entity._id.toString());
    });

    it('should update entity status', async () => {
      const entity = await testHelper
        .factoryBuilder(MyEntityFactory)
        .create({
          companyId,
          status: StatusEnum.Pending,
        });

      const { error, data } = await testHelper
        .get(ApproveUseCase)
        .execute({
          id: entity._id.toString(),
          reviewer,
        });

      expect(error).toBeNull();
      expect(data.status).toBe(StatusEnum.Approved);

      // Verify in database
      const updatedEntity = await testHelper
        .get(MyRepository)
        .findOneById(`${entity._id}`);

      expect(updatedEntity?.status).toBe(StatusEnum.Approved);
    });
  });
});
```

## Factory Pattern for Testing

```typescript
import { faker } from '@faker-js/faker';
import mongoose from 'mongoose';

import { MyEntity } from '@/cores/entities/my-entity/entity';
import { StatusEnum } from '@/cores/entities/my-entity/enums';
import { MyRepository } from '@/cores/repositories/my-entity/repository';
import { InjectRepository } from '../decorators/inject-repository.decorator';

@InjectRepository(MyRepository)
export class MyEntityFactory {
  static create(override?: Partial<MyEntity>): MyEntity {
    const entity: MyEntity = {
      _id: new mongoose.Types.ObjectId(),
      displayId: `MY${faker.string.numeric(4)}`,
      companyId: new mongoose.Types.ObjectId().toString(),
      status: faker.helpers.enumValue(StatusEnum),
      createdBy: {
        id: new mongoose.Types.ObjectId().toString(),
        name: faker.person.fullName(),
      },
      updatedBy: {
        id: new mongoose.Types.ObjectId().toString(),
        name: faker.person.fullName(),
      },
      createdAt: faker.date.past(),
      updatedAt: faker.date.past(),
      ...override,
    };

    return entity;
  }

  static createMany(num: number, override?: Partial<MyEntity>): MyEntity[] {
    return Array.from({ length: num }, () => this.create(override));
  }
}
```

Usage:

```typescript
// Create single entity in database
const entity = await testHelper
  .factoryBuilder(MyEntityFactory)
  .create({
    companyId,
    status: StatusEnum.Pending,
  });

// Create multiple entities
await testHelper
  .factoryBuilder(MyEntityFactory)
  .createMany(5, {
    companyId,
  });
```

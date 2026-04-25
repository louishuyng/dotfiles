---
name: usecase-regask
description: Best practices for creating NestJS usecases in Regask, including structure, error handling
---

## Steps
1. Following TDD to create solid usecase
2. First setup empty usecase and import to module correctly
3. Define input/output types in separate `types.ts` file using namespaces
4. Write a test for the success path first, using factoryBuilder to create necessary data. Make sure test fails before implementing the usecase logic.
5. Implement the usecase logic in `handle()` method, organizing code with private methods by concern (e.g. guard checks, business logic, side effects).
6. Run the test and ensure it passes.
7. Write additional tests for error paths (not found, business rule violation, permission denied) and implement necessary logic to make them pass.
8. If you find reusable logic that can be extracted into a concern, create a concern class and inject it into the usecase.
9. If you find usecase too big or doing too many things, break it down into smaller focused usecases and orchestrate them if needed.
10. If extract to usecase or concern, make sure to follow TDD again and reduce the test scope of the original usecase to only test the orchestration or integration of the smaller pieces.

# Creating NestJS Usecases

## Usecase Structure

Every usecase must:
1. Extend `BaseUseCase<Input, Output>`
2. Define clear input/output types using namespaces
3. Organize `handle()` method with private methods by concern
4. Return `UseCaseResult<Output>` with structured error handling

### Basic Usecase Template

```typescript
import { Injectable } from '@nestjs/common';
import { Logger } from '@regask/common-lib/logger/logger.service';
import { BaseUseCase, UseCaseResult } from '@regask/common-lib/workflow';
import {
  BusinessRuleException,
  NotFoundException,
  PermissionDeniedException,
} from '@regask/common-lib/workflow/types';

import { MyUseCaseTypes } from './types';

type Input = MyUseCaseTypes.Input;
type Output = MyUseCaseTypes.Output;

@Injectable()
export class MyUseCase extends BaseUseCase<Input, Output> {
  constructor(
    private myRepository: MyRepository,
    private myConcern: MyConcern,
  ) {
    super();
    this.logger = new Logger(MyUseCase.name);
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    // 1. Guard checks (validation, authorization)
    await this.#guardChecks(input);

    // 2. Main business logic
    const result = await this.#executeBusinessLogic(input);

    // 3. Side effects (events, notifications)
    await this.#publishEvents(result);

    return {
      data: result,
      error: null,
    };
  }

  async #guardChecks(input: Input): Promise<void> {
    // Validation and authorization logic
  }

  async #executeBusinessLogic(input: Input): Promise<Output> {
    // Core business logic
  }

  async #publishEvents(data: Output): Promise<void> {
    // Event publishing / side effects
  }
}
```

## Input/Output Types

Define types in a separate `types.ts` file using namespaces:

```typescript
import { AuditUser } from '@regask/common-lib/microservices/identity/types/audit-user.type';
import { MyEntity } from '@/cores/entities/my-entity/entity';

export namespace MyUseCaseTypes {
  export type Input = {
    id: string;                    // Required fields first
    userId: string;
    companyId: string;
    remarks?: string;              // Optional fields with ?
    reviewer?: AuditUser;          // Use AuditUser for user context
  };

  export type Output = MyEntity;
}
```

**Important: Use `AuditUser` for User Context**

For actors like `reviewer`, `approver`, `submitter`, or any user performing an action, **always use `AuditUser`** from common-lib instead of creating custom types. `AuditUser` is the standard user context type across the system and includes:
- `userId`, `userCompany`, `userRole`
- `firstName`, `lastName`, `email`
- `permission` (RBAC permissions)
- And other user context fields

```typescript
// GOOD: Use AuditUser for user actors
export type Input = {
  id: string;
  reviewer: AuditUser;  // Standard user context
};

// BAD: Don't create custom user types for actors
export type Input = {
  id: string;
  reviewer: {           // Avoid custom actor types
    id: string;
    name: string;
  };
};
```

For complex inputs with pagination/sorting:

```typescript
export namespace FetchDataGridUseCaseTypes {
  export type Sort = {
    sortBy?: string;
    sortDirection?: 'asc' | 'desc';
  };

  export type Pagination = {
    page?: number;
    limit?: number;
  };

  export type Input = {
    companyId: string;
    userId: string;
    filter?: GridFilterModel;
    searchKey?: string;
    pagination?: Pagination;
    sorts?: Sort[];
  };

  export type Output = {
    total: number;
    items: MyEntity[];
  };
}
```

## Handle Method Organization

Organize code in `handle()` with clear separation:

```typescript
async handle(input: Input): Promise<UseCaseResult<Output>> {
  this.logger.info(`Executing usecase ${MyUseCase.name}`, { input });

  // 1. Build filters and search criteria
  const searchFilter = this.#buildSearchFilter(input);

  // 2. Parallelize independent operations
  const [total, items] = await Promise.all([
    this.#getFilteredRecordCount(searchFilter),
    this.#executeSearchQuery(input, searchFilter),
  ]);

  // 3. Return result
  return {
    error: null,
    data: { total, items },
  };
}
```

## Error Handling

Use specific exception types with error codes:

```typescript
// Not found
throw new NotFoundException('entity_not_found').withErrorCode('ENTITY_NOT_FOUND');

// Business rule violation
throw new BusinessRuleException('entity_not_pending').withErrorCode('ENTITY_NOT_PENDING');

// Permission denied
throw new PermissionDeniedException('user_not_allowed').withErrorCode('USER_NOT_ALLOWED');
```

## Concerns Pattern

### When to Extract Concerns

Extract logic into concerns when:
- Logic is reused across multiple usecases
- A single responsibility can be isolated
- Logic becomes complex enough to warrant separate testing

### Concern Structure

Place concerns in:
- `workflows/shared/concerns/` - for cross-workflow concerns
- `workflows/{workflow-name}/concerns/` - for workflow-specific concerns

```typescript
import { Injectable } from '@nestjs/common';
import { PermissionDeniedException } from '@regask/common-lib/workflow/types';

@Injectable()
export class RbacPermissionConcern {
  guardApproval(reviewer: AuditUser, purpose: PurposeEnum): void {
    if (!this.#hasPermissionForPurpose(reviewer, purpose)) {
      throw new PermissionDeniedException(
        'user_not_allowed_to_approve',
      ).withErrorCode('USER_NOT_ALLOWED_TO_APPROVE');
    }
  }

  #hasPermissionForPurpose(reviewer: AuditUser, purpose: PurposeEnum): boolean {
    const permissionMapping = PURPOSE_PERMISSION_MAP[purpose];
    if (!permissionMapping) return false;

    const { module, action } = permissionMapping;
    return reviewer.permission?.[module]?.[action] === true;
  }
}
```

### Using Concerns in Usecases

```typescript
@Injectable()
export class ApproveUseCase extends BaseUseCase<Input, Output> {
  constructor(
    private rbacPermissionConcern: RbacPermissionConcern,
  ) {
    super();
  }

  async #guardCheckApproval(input: Input): Promise<void> {
    this.rbacPermissionConcern.guardApproval(
      input.reviewer,
      input.purpose,
    );
  }
}
```

## Breaking Large Usecases

When a usecase does too many things:
1. Identify distinct operations
2. Create smaller focused usecases
3. Orchestrate from a parent usecase if needed

```typescript
// Instead of one large usecase doing everything:
// ProcessOrderUseCase (validates, creates, notifies, updates inventory)

// Break into:
// ValidateOrderUseCase
// CreateOrderUseCase
// NotifyOrderCreatedUseCase
// UpdateInventoryUseCase

// Orchestrate if needed:
@Injectable()
export class ProcessOrderUseCase extends BaseUseCase<Input, Output> {
  constructor(
    private validateOrderUseCase: ValidateOrderUseCase,
    private createOrderUseCase: CreateOrderUseCase,
    private notifyOrderCreatedUseCase: NotifyOrderCreatedUseCase,
  ) {
    super();
  }

  async handle(input: Input): Promise<UseCaseResult<Output>> {
    await this.validateOrderUseCase.executeOrThrowHttpError(input);
    const order = await this.createOrderUseCase.executeOrThrowHttpError(input);
    await this.notifyOrderCreatedUseCase.execute({ order });

    return { data: order, error: null };
  }
}
```

# Testing Usecases

## Test Setup

```typescript
import { CustomTestHelper } from '@/test-helper/custom.test-helper';
import { AppModule } from '@/app.module';
import { CONNECTION_NAME } from '@/infra/database/constant';

describe('@workflows/my-workflow/my-usecase', () => {
  const testHelper = new CustomTestHelper(CONNECTION_NAME, AppModule);

  beforeAll(async () => {
    await testHelper.beforeAll();
  });

  afterAll(() => testHelper.afterAll());
  afterEach(() => testHelper.cleanUp());
});
```

## Using FactoryBuilder

**ALWAYS use factoryBuilder for database interactions. NEVER use toBeDefined() for assertions.**

```typescript
// Create single entity
const entity = await testHelper
  .factoryBuilder(MyEntityFactory)
  .create({
    companyId,
    status: StatusEnum.Pending,
  });

// Create multiple entities
await testHelper
  .factoryBuilder(MyEntityFactory)
  .createMany(3, {
    companyId,
  });
```

## Test Patterns

### Success Path

```typescript
describe('when entity exists and user has permission', () => {
  it('should update status to Approved', async () => {
    const companyId = new mongoose.Types.ObjectId().toString();
    const reviewer = createUserWithPermission({ userCompany: companyId });

    const pendingEntity = await testHelper
      .factoryBuilder(MyEntityFactory)
      .create({
        companyId,
        status: StatusEnum.Pending,
      });

    const { error, data } = await testHelper
      .get(ApproveUseCase)
      .execute({
        id: pendingEntity._id.toString(),
        reviewer,
      });

    expect(error).toBeNull();
    expect(data.status).toBe(StatusEnum.Approved);
    expect(data.review.reviewer.id).toBe(reviewer.userId);
  });
});
```

### Error Path - Not Found

```typescript
describe('when entity does not exist', () => {
  it('should return error code ENTITY_NOT_FOUND', async () => {
    const companyId = new mongoose.Types.ObjectId().toString();
    const reviewer = createUserWithPermission({ userCompany: companyId });
    const nonExistentId = new mongoose.Types.ObjectId().toString();

    const { error } = await testHelper
      .get(ApproveUseCase)
      .execute({
        id: nonExistentId,
        reviewer,
      });

    expect(error.type).toBe(UseCaseErrorType.NOT_FOUND);
    expect(error.data.errorCode).toBe('entity_not_found');
  });
});
```

### Error Path - Business Rule

```typescript
describe('when entity is not pending', () => {
  it('should return error code ENTITY_NOT_PENDING', async () => {
    const companyId = new mongoose.Types.ObjectId().toString();
    const reviewer = createUserWithPermission({ userCompany: companyId });

    const approvedEntity = await testHelper
      .factoryBuilder(MyEntityFactory)
      .create({
        companyId,
        status: StatusEnum.Approved,
      });

    const { error } = await testHelper
      .get(ApproveUseCase)
      .execute({
        id: approvedEntity._id.toString(),
        reviewer,
      });

    expect(error.type).toBe(UseCaseErrorType.BUSINESS_RULE);
    expect(error.data.errorCode).toBe('entity_not_pending');
  });
});
```

### Error Path - Permission Denied

```typescript
describe('when user does not have permission', () => {
  it('should return error code USER_NOT_ALLOWED', async () => {
    const companyId = new mongoose.Types.ObjectId().toString();
    const reviewerWithoutPermission = AuditUserFactory.create({
      userCompany: companyId,
      permission: {
        [ClientModuleEnum.CLIENT__ALERT]: {
          [ClientAlertActionEnum.APPROVE_ALERTS]: false,
        },
      } as PermissionValueObject,
    });

    const pendingEntity = await testHelper
      .factoryBuilder(MyEntityFactory)
      .create({
        companyId,
        status: StatusEnum.Pending,
      });

    const { error } = await testHelper
      .get(ApproveUseCase)
      .execute({
        id: pendingEntity._id.toString(),
        reviewer: reviewerWithoutPermission,
      });

    expect(error.type).toBe(UseCaseErrorType.PERMISSION_DENIED);
    expect(error.data.errorCode).toBe('user_not_allowed');
  });
});
```

### Testing Side Effects (Kafka)

```typescript
describe('when signaling event', () => {
  it('should send Kafka message', async () => {
    const companyId = new mongoose.Types.ObjectId().toString();
    const entityId = new mongoose.Types.ObjectId().toString();
    const reviewer = createUserWithPermission({ userCompany: companyId });

    const pendingEntity = await testHelper
      .factoryBuilder(MyEntityFactory)
      .create({
        companyId,
        entityId,
        status: StatusEnum.Pending,
      });

    const sendKafkaMessageSpy = jest.spyOn(
      testHelper.get(KafkaProducerV2Service),
      'sendMessage',
    );

    const { error, data } = await testHelper
      .get(ApproveUseCase)
      .execute({
        id: pendingEntity._id.toString(),
        reviewer,
      });

    expect(error).toBeNull();
    expect(sendKafkaMessageSpy).toHaveBeenCalledTimes(1);
    expect(sendKafkaMessageSpy).toHaveBeenCalledWith(
      EventTopicEnumV2.MyEventTopic,
      {
        eventBody: {
          entityId: data._id.toString(),
          companyId: entityId,
        },
        eventMetadata: {},
      },
    );
  });
});
```

## Factory Implementation

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
      displayId: `MY${faker.string.numeric(2)}`,
      companyId: new mongoose.Types.ObjectId().toString(),
      status: faker.helpers.enumValue(StatusEnum),
      createdBy: {
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

## Test Helper Functions

Create reusable helper functions for common test setups:

```typescript
const createUserWithPermission = (
  overrides: Partial<AuditUser> = {},
): AuditUser =>
  AuditUserFactory.create({
    ...overrides,
    permission: {
      [ClientModuleEnum.CLIENT__ALERT]: {
        [ClientAlertActionEnum.APPROVE_ALERTS]: true,
      },
    } as PermissionValueObject,
  });
```

---
name: router-regask
description: Best practices for creating NestJS routers/controllers in Regask, including usecase integration, response mapping, error handling, and testing.
---

## Steps
1. Creating router definition in router config
2. Create empty controller and add to module
3. Implement test for controller make sure it fails
4. Implement controller logic with usecase and mappers
5. Run test and make sure it passes
6. For decorators, using existing ones from common-lib (e.g. `@GetAuditUser`, `@CompanyFeatureFlag, @RbacPermissions`) or create new ones if needed
7. Make sure swagger documentation is added for the controller and its methods using `@ApiTags`, `@ApiOperation`, and response decorators (e.g. `@ApiOkResponse`, `@ApiBadRequestResponse`)

# Creating NestJS Routers/Controllers

## Controller Structure

Every controller must:
1. Use appropriate decorators (`@Controller`, `@ApiTags`, `@ApiOperation`)
2. Call usecases with `executeOrThrowHttpError`
3. Use mappers for complex response data
4. Handle feature flags when required

### Basic Controller Template

```typescript
import { Body, Controller, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { GetAuditUser } from '@regask/common-lib/decorators';
import { AuditUser } from '@regask/common-lib/microservices/identity/types/audit-user.type';
import { CompanyFeatureFlag } from '@regask/common-lib/decorators/company-feature-flag.decorator';
import { FeatureFlagEnum } from '@regask/common-lib/enums';

import { Routes, RouteVersion } from '@/routers/routes';
import { MyUseCase } from '@/workflows/my-workflow/usecase';

import { MyRequestDto } from './request.dto';
import { MyResponseDto } from './response.dto';
import { ResponseMapper } from './mapper';

@Controller({
  version: [RouteVersion.v2],
  path: Routes.myResource.action,
})
@ApiTags('My Resource')
export class MyController {
  constructor(private readonly myUseCase: MyUseCase) {}

  @Post()
  @ApiOkResponse({ type: MyResponseDto })
  @ApiOperation({ summary: 'Perform action on resource' })
  @CompanyFeatureFlag(FeatureFlagEnum.myFeatureFlag)
  @HttpCode(HttpStatus.OK)
  async post(
    @GetAuditUser() user: AuditUser,
    @Param('id') id: string,
    @Body() body: MyRequestDto,
  ): Promise<MyResponseDto> {
    const data = await this.myUseCase.executeOrThrowHttpError({
      id,
      reviewer: user,
      remarks: body.remarks,
    });

    return ResponseMapper.toMyResponseDto(data);
  }
}
```

## Calling Usecases

### Using executeOrThrowHttpError (Preferred)

Use `executeOrThrowHttpError` when you want automatic HTTP error handling:

```typescript
async post(
  @GetAuditUser() user: AuditUser,
  @Param('id') id: string,
  @Body() body: MyRequestDto,
): Promise<MyResponseDto> {
  const data = await this.myUseCase.executeOrThrowHttpError({
    id,
    reviewer: user,
    remarks: body.remarks,
  });

  return ResponseMapper.toMyResponseDto(data);
}
```

### Using execute() + throwIfHaveErrorInUseCase

Use this pattern when you need to access both data and error:

```typescript
import { throwIfHaveErrorInUseCase } from '@regask/common-lib/controllers/usecaseErrorHandler';

async post(
  @GetAuditUser() user: AuditUser,
  @Body() body: MyRequestDto,
): Promise<MyResponseDto> {
  const { error, data } = await this.myUseCase.execute({
    companyId: user.userCompany,
    userId: user.userId,
    filter: body.filter,
    pagination: body.pagination,
  });

  throwIfHaveErrorInUseCase(error);

  return {
    total: data.total,
    items: mapToDataGridItems(data.items),
  };
}
```

### Error Type to HTTP Status Mapping

| UseCaseErrorType | HTTP Status |
|------------------|-------------|
| INVALID_INPUT | 400 Bad Request |
| NOT_FOUND | 404 Not Found |
| CONFLICT | 409 Conflict |
| BUSINESS_RULE | 422 Unprocessable Entity |
| PERMISSION_DENIED | 403 Forbidden |
| INTERNAL_SERVER_ERROR | 500 Internal Server Error |

## Response Mappers

### When to Use Mappers

Use mappers when:
- Converting entity to DTO with field renaming
- Transforming ObjectId to string
- Conditional field mapping
- Complex nested object transformation

### Static Mapper Class Pattern

```typescript
import { MyEntity } from '@/cores/entities/my-entity/entity';
import { MyResponseDto } from './response.dto';

export class ResponseMapper {
  static toMyResponseDto(data: MyEntity): MyResponseDto {
    return {
      id: data._id.toString(),           // Convert ObjectId
      displayId: data.displayId,
      status: data.approvalStatus,        // Rename field
      type: data.entity,
      review: data.review                 // Conditional mapping
        ? {
            reviewer: {
              id: data.review.reviewer.id,
              name: data.review.reviewer.name,
            },
            reviewedAt: data.review.reviewedAt,
            action: data.review.action,
            remarks: data.review.remarks,
          }
        : undefined,
    };
  }

  // Reuse mappers for similar responses
  static toAnotherResponseDto(data: MyEntity): AnotherResponseDto {
    return this.toMyResponseDto(data);
  }
}
```

### Function Mapper Pattern

```typescript
export function mapToDataGridItems(
  items: MyEntity[],
): DataGridItem[] {
  return items.map((item) => ({
    id: item._id.toString(),
    title: item.entityTitle,
    status: item.approvalStatus,
    lastSubmittedBy: {
      id: item.updatedBy.id,
      name: item.updatedBy.name,
    },
    lastSubmittedAt: item.updatedAt,
  }));
}
```

## 204 No Content Responses

For operations that don't return data:

```typescript
@Controller({
  version: [RouteVersion.v2],
})
@ApiTags('My Resource')
export class UpdateController {
  constructor(private readonly updateUseCase: UpdateUseCase) {}

  @Patch(Routes.myResource.update)
  @HttpCode(HttpStatus.NO_CONTENT)              // Returns 204
  @ApiOperation({ summary: 'Update resource' })
  @ApiResponse({
    status: HttpStatus.NO_CONTENT,
    description: 'Resource updated successfully',
  })
  async update(
    @Body() body: UpdateRequestDto,
  ): Promise<void> {                             // No return data
    const { error } = await this.updateUseCase.execute({
      resourceId: body.resourceId,
      data: body.data,
    });
    throwIfHaveErrorInUseCase(error);
  }
}
```

# Testing Routers

## Test Setup

```typescript
import { CustomTestHelper } from '@/test-helper/custom.test-helper';
import { AppModule } from '@/app.module';
import { CONNECTION_NAME } from '@/infra/database/constant';
import { v2Prefix } from '@/routers/routes';

describe('@routers/v2/my-resource/action', () => {
  const testHelper = new CustomTestHelper(CONNECTION_NAME, AppModule);

  beforeAll(async () => {
    await testHelper.beforeAll();
  });

  afterAll(() => testHelper.afterAll());
});
```

## Test Patterns with executedWithUsecase, withFeatureFlags, requestedBy

### Success Response (200 OK)

```typescript
it('Should return 200 with response data', async () => {
  const resourceId = new mongoose.Types.ObjectId().toString();
  const authorizedUser = AuditUserFactory.create({
    userRole: Role.CLIENTADMIN,
  });

  const entity = MyEntityFactory.create({
    _id: new mongoose.Types.ObjectId(resourceId),
    companyId: authorizedUser.userCompany,
    status: StatusEnum.Approved,
  });

  const url = `${v2Prefix}/${Routes.myResource.action.replace(':id', resourceId)}`;

  const res = await testHelper.request
    .post(url)
    .send({ remarks: 'Test remarks' })
    .requestedBy(authorizedUser)                    // Set user context
    .withFeatureFlags(FeatureFlagEnum.myFeature)    // Enable feature flag
    .executedWithUsecase({
      usecase: MyUseCase,
      expectedInput: {                              // Verify input
        id: resourceId,
        reviewer: authorizedUser,
        remarks: 'Test remarks',
      },
      mockOutput: {                                 // Mock response
        data: entity,
        error: null,
      },
    })
    .expect(200);

  expect(res.body.id).toBe(entity._id.toString());
  expect(res.body.status).toBe(StatusEnum.Approved);
});
```

### Business Error Response (422)

```typescript
it('Should return 422 if usecase returns business error', async () => {
  const resourceId = new mongoose.Types.ObjectId().toString();
  const authorizedUser = AuditUserFactory.create({
    userRole: Role.CLIENTADMIN,
  });

  const url = `${v2Prefix}/${Routes.myResource.action.replace(':id', resourceId)}`;

  const res = await testHelper.request
    .post(url)
    .send({})
    .requestedBy(authorizedUser)
    .withFeatureFlags(FeatureFlagEnum.myFeature)
    .executedWithUsecase({
      usecase: MyUseCase,
      expectedInput: {
        id: resourceId,
        reviewer: authorizedUser,
        remarks: undefined,
      },
      mockOutput: {
        data: null,
        error: new UseCaseError(
          'entity_not_pending',
          UseCaseErrorType.BUSINESS_RULE,
        ),
      },
    })
    .expect(422);

  expect(res.body.message).toBe('entity_not_pending');
});
```

### Not Found Error (404)

```typescript
it('Should return 404 if entity not found', async () => {
  const resourceId = new mongoose.Types.ObjectId().toString();
  const authorizedUser = AuditUserFactory.create();

  const url = `${v2Prefix}/${Routes.myResource.action.replace(':id', resourceId)}`;

  const res = await testHelper.request
    .post(url)
    .send({})
    .requestedBy(authorizedUser)
    .withFeatureFlags(FeatureFlagEnum.myFeature)
    .executedWithUsecase({
      usecase: MyUseCase,
      expectedInput: {
        id: resourceId,
        reviewer: authorizedUser,
        remarks: undefined,
      },
      mockOutput: {
        data: null,
        error: new UseCaseError(
          'Entity not found',
          UseCaseErrorType.NOT_FOUND,
        ),
      },
    })
    .expect(404);
});
```

### Validation Error (400)

```typescript
it('Should return 400 if required field is missing', async () => {
  const resourceId = new mongoose.Types.ObjectId().toString();
  const authorizedUser = AuditUserFactory.create({
    userRole: Role.CLIENTADMIN,
  });

  const url = `${v2Prefix}/${Routes.myResource.action.replace(':id', resourceId)}`;

  const res = await testHelper.request
    .post(url)
    .send({})                                       // Missing required field
    .requestedBy(authorizedUser)
    .withFeatureFlags(FeatureFlagEnum.myFeature)
    .expect(400);

  expect(res.body.message).toContain('remarks should not be empty');
});
```

### 204 No Content Test

```typescript
describe('When usecase executes successfully', () => {
  it('Should return 204 No Content', async () => {
    const body = {
      resourceId: 'some-resource-id',
      data: ['item1', 'item2'],
    };

    await testHelper.request
      .patch(UpdateUrl)
      .send(body)
      .requestedBy(authorizedUser)
      .executedWithUsecase({
        usecase: UpdateUseCase,
        expectedInput: {
          resourceId: body.resourceId,
          data: body.data,
        },
        mockOutput: {
          data: null,                              // No data for 204
          error: null,
        },
      })
      .expect(204);
  });
});
```

## Test Helper Methods

| Method | Purpose |
|--------|---------|
| `.requestedBy(user)` | Set `AuditUser` in request headers |
| `.withFeatureFlags(...flags)` | Enable feature flags for request |
| `.executedWithUsecase({...})` | Spy on usecase, verify input, mock output |
| `.expect(statusCode)` | Assert HTTP response status |

## Bulk Operations

```typescript
async post(
  @GetAuditUser() user: AuditUser,
  @Body() body: BulkApproveRequestDto,
): Promise<BulkApprovedResponseDto> {
  const { approvalIds, remarks } = body;
  const { approvedList, approvedCount, totalCount } =
    await this.bulkApproveUseCase.executeOrThrowHttpError({
      approvalIds,
      reviewer: user,
      remarks,
    });

  return {
    totalCount,
    approvedCount,
    items: approvedList.map((item) =>
      ResponseMapper.toMyResponseDto(item),
    ),
  };
}
```

## Feature Flag Guards

```typescript
import { CompanyFeatureFlag } from '@regask/common-lib/decorators/company-feature-flag.decorator';
import { FeatureFlagEnum } from '@regask/common-lib/enums';

@Controller({
  version: [RouteVersion.v2],
  path: Routes.myResource.action,
})
export class MyController {
  @Post()
  @CompanyFeatureFlag(FeatureFlagEnum.myFeatureFlag)  // Guard with feature flag
  async post(...): Promise<MyResponseDto> {
    // Only accessible when feature flag is enabled
  }
}
```

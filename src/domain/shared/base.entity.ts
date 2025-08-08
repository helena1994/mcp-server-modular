export abstract class BaseEntity {
  abstract readonly id: string;
  readonly createdAt?: Date;
  readonly updatedAt?: Date;
}

import { BaseEntity } from '../shared/base.entity';
import { UserProps } from './user.types';

export class User extends BaseEntity {
  readonly id: string;
  readonly email: string;
  passwordHash: string;
  displayName?: string | null;
  createdAt?: Date;
  updatedAt?: Date;

  private constructor(props: UserProps) {
    super();
    Object.assign(this, props);
  }

  static create(props: UserProps) {
    return new User(props);
  }
}

export interface RoleProps {
  id: string;
  name: string;
  description?: string | null;
}

export class Role {
  readonly id: string;
  readonly name: string;
  readonly description?: string | null;
  private constructor(props: RoleProps) { Object.assign(this, props); }
  static create(props: RoleProps) { return new Role(props); }
}

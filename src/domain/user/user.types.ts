export interface UserProps {
  id: string;
  email: string;
  passwordHash: string;
  displayName?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}

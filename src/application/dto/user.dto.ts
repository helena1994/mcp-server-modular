export interface RegisterUserDTO {
  email: string;
  password: string;
  displayName?: string;
}

export interface LoginUserDTO {
  email: string;
  password: string;
}

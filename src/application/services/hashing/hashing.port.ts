export interface IHashingService {
  hash(raw: string): Promise<string>;
  verify(hash: string, raw: string): Promise<boolean>;
}

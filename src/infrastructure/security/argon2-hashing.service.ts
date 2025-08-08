import argon2 from 'argon2';
import { IHashingService } from '../../application/services/hashing/hashing.port';

export class Argon2HashingService implements IHashingService {
  hash(raw: string): Promise<string> { return argon2.hash(raw); }
  verify(hash: string, raw: string): Promise<boolean> { return argon2.verify(hash, raw); }
}

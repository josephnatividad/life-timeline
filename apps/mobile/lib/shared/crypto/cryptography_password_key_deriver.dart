import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart' as crypto_helpers;
import 'package:life_timeline/shared/crypto/crypto_models.dart';

final class CryptographyPasswordKeyDeriver implements PasswordKeyDeriver {
  const CryptographyPasswordKeyDeriver();

  @override
  Future<List<int>> derive({
    required String password,
    required List<int> salt,
    required KdfParameters parameters,
  }) async {
    parameters.validate();
    final key = await Argon2id(
      parallelism: parameters.parallelism,
      memory: parameters.memoryKiB,
      iterations: parameters.iterations,
      hashLength: parameters.hashLength,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    // `extractBytes` may return an immutable sensitive-byte view. Keep a
    // mutable application-owned copy so callers can overwrite it after use.
    return List<int>.of(await key.extractBytes(), growable: false);
  }

  @override
  List<int> randomBytes(int length) => crypto_helpers.randomBytes(length);

  @override
  bool secureEquals(List<int> left, List<int> right) =>
      crypto_helpers.constantTimeBytesEquality.equals(left, right);
}

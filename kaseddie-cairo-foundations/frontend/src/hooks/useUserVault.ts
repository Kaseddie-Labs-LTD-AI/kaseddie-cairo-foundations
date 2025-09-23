import { useContract } from '@starknet-react/core';
import vaultAbi from '../abi/UserVault.json';

export function useUserVault() {
  const address = process.env.REACT_APP_VAULT_ADDRESS;
  if (!address || address === '0x0000000000000000000000000000000000000000000000000000000000000000') {
    console.warn('No valid contract address set; using mock or empty contract');
    return null; // Or return a mock contract for testing
  }
  const { contract } = useContract({ abi: vaultAbi, address });
  return contract;
}

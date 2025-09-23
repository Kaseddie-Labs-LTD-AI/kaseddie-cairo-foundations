// src/components/BalanceDisplay.tsx
import React, { useState, useEffect } from 'react';
import { useStarknet } from 'starknet-react';
import { useUserVault } from '../hooks/useUserVault';

export function BalanceDisplay() {
  const { account } = useStarknet();
  const vault = useUserVault();
  const [balance, setBalance] = useState<bigint>(0n);

  const refresh = async () => {
    const res = await vault.call('get_balance', [account!]);
    setBalance(res[0]);
  };

  useEffect(() => {
    if (account) refresh();
  }, [account, vault]);

  return (
    <div>
      <p>Your Balance: {balance.toString()}</p>
      <button onClick={refresh}>Refresh</button>
    </div>
  );
}

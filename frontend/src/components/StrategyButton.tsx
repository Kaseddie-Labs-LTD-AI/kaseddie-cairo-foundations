// src/components/StrategyButton.tsx
import React, { useState, useEffect } from 'react';
import { useStarknet } from 'starknet-react';
import { useUserVault } from '../hooks/useUserVault';

export function StrategyButton({ onDone }: { onDone: () => void }) {
  const { account } = useStarknet();
  const vault = useUserVault();
  const [activated, setActivated] = useState(false);
  const [loading, setLoading] = useState(false);

  // check if already activated
  useEffect(() => {
    vault.call('is_strategy_active', [account!]).then(res => {
      setActivated(res[0].toBoolean());
    });
  }, [account, vault]);

  const handleActivate = async () => {
    setLoading(true);
    try {
      if (activated) return;
      const tx = await vault.invoke('activate_strategy', [], { from: account! });
      await tx.wait();
      setActivated(true);
      onDone();
    } catch {/* ignore */} finally {
      setLoading(false);
    }
  };

  return (
    <button disabled={loading || activated} onClick={handleActivate}>
      {activated ? 'Strategy Active' : loading ? 'Activating…' : 'Activate Strategy'}
    </button>
  );
}

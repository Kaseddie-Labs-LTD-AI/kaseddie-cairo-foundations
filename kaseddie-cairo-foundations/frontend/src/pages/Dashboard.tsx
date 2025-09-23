// src/pages/Dashboard.tsx
import React from 'react';
import { KycForm } from '../components/KycForm';
import { DepositForm } from '../components/DepositForm';
import { WithdrawForm } from '../components/WithdrawForm';
import { StrategyButton } from '../components/StrategyButton';
import { BalanceDisplay } from '../components/BalanceDisplay';

export default function Dashboard() {
  const reloadAll = () => {
    // could trigger context or events to refresh each component
  };

  return (
    <main>
      <h1>User Vault Dashboard</h1>
      <KycForm />
      <BalanceDisplay />
      <DepositForm onDone={reloadAll} />
      <WithdrawForm onDone={reloadAll} />
      <StrategyButton onDone={reloadAll} />
    </main>
  );
}

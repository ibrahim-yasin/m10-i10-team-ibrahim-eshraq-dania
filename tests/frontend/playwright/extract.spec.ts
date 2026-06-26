import { test, expect } from '@playwright/test';

test('extract page renders and submits text', async ({ page }) => {
  await page.goto('http://localhost:3000/extract');

  const input = page.getByRole('textbox').first();
  await input.fill('Ginger and garlic are ingredients used in stir-fry.');

  const button = page.getByRole('button').first();
  await button.click();

  await expect(page.locator('body')).toContainText(/ginger|garlic|entity|extract|result/i);
});

import { test, expect } from '@playwright/test';

test('kg page renders and submits query', async ({ page }) => {
  await page.goto('http://localhost:3000/kg');

  const input = page.getByRole('textbox').first();
  await input.fill('What ingredients are used for stir-fry?');

  const button = page.getByRole('button').first();
  await button.click();

  await expect(page.locator('body')).toContainText(/ingredient|ginger|query|result|kg/i);
});

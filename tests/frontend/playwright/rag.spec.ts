import { test, expect } from '@playwright/test';

test('rag page renders seeded answer with citation', async ({ page }) => {
  await page.goto('http://localhost:3000/rag');

  const input = page.getByRole('textbox').first();
  await input.fill('How do I prep ginger for stir-fry?');

  const button = page.getByRole('button').first();
  await button.click();

  await expect(page.locator('body')).toContainText(/Confidence/i);
  await expect(page.locator('body')).toContainText(/\[[0-9]+\]/);
});

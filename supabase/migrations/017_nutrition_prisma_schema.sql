-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "nutrition";

-- CreateEnum
CREATE TYPE "nutrition"."MealType" AS ENUM ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'CUSTOM');

-- CreateEnum
CREATE TYPE "nutrition"."AmountUnit" AS ENUM ('GRAM', 'SERVING');

-- CreateEnum
CREATE TYPE "nutrition"."FoodSource" AS ENUM ('MANUAL', 'USDA', 'OPEN_FOOD_FACTS', 'LLM');

-- CreateEnum
CREATE TYPE "nutrition"."BuddyStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED');

-- CreateEnum
CREATE TYPE "nutrition"."ReactionType" AS ENUM ('THUMBS_UP', 'THUMBS_DOWN', 'FIRE', 'MUSCLE');

-- CreateTable
CREATE TABLE "nutrition"."users" (
    "id" UUID NOT NULL,
    "username" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."user_profiles" (
    "id" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "kcalTarget" DOUBLE PRECISION NOT NULL DEFAULT 2000,
    "proteinTarget" DOUBLE PRECISION NOT NULL DEFAULT 120,
    "carbsTarget" DOUBLE PRECISION NOT NULL DEFAULT 250,
    "fatTarget" DOUBLE PRECISION NOT NULL DEFAULT 70,
    "fiberTarget" DOUBLE PRECISION DEFAULT 30,
    "heightCm" DOUBLE PRECISION,
    "weightKg" DOUBLE PRECISION,
    "age" INTEGER,
    "gender" TEXT,
    "equipmentPreset" TEXT,
    "equipment" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "allergies" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "dietaryRestrictions" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "healthConditions" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "onboardingCompleted" BOOLEAN NOT NULL DEFAULT false,
    "locale" TEXT NOT NULL DEFAULT 'fr',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."foods" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "brand" TEXT,
    "source" "nutrition"."FoodSource" NOT NULL DEFAULT 'MANUAL',
    "createdByUserId" UUID,
    "barcode" TEXT,
    "offUrl" TEXT,
    "offLastFetchedAt" TIMESTAMP(3),
    "kcalPer100g" DOUBLE PRECISION NOT NULL,
    "proteinPer100g" DOUBLE PRECISION NOT NULL,
    "carbsPer100g" DOUBLE PRECISION NOT NULL,
    "fatPer100g" DOUBLE PRECISION NOT NULL,
    "fiberPer100g" DOUBLE PRECISION,
    "sodiumMgPer100g" DOUBLE PRECISION,
    "servingName" TEXT,
    "servingGrams" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "foods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."log_entries" (
    "id" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "date" TEXT NOT NULL,
    "mealType" "nutrition"."MealType" NOT NULL,
    "mealName" TEXT,
    "amount" DOUBLE PRECISION NOT NULL,
    "unit" "nutrition"."AmountUnit" NOT NULL DEFAULT 'GRAM',
    "sourceText" TEXT,
    "isEstimated" BOOLEAN NOT NULL DEFAULT false,
    "estimationMeta" JSONB,
    "snapshotKcal" DOUBLE PRECISION,
    "snapshotProteinG" DOUBLE PRECISION,
    "snapshotCarbsG" DOUBLE PRECISION,
    "snapshotFatG" DOUBLE PRECISION,
    "snapshotFiberG" DOUBLE PRECISION,
    "foodId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "log_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."buddy_relationships" (
    "id" TEXT NOT NULL,
    "requesterId" UUID NOT NULL,
    "addresseeId" UUID NOT NULL,
    "status" "nutrition"."BuddyStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "buddy_relationships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."reactions" (
    "id" TEXT NOT NULL,
    "logEntryId" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "type" "nutrition"."ReactionType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."weight_entries" (
    "id" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "weightKg" DOUBLE PRECISION NOT NULL,
    "date" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "weight_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."water_entries" (
    "id" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "date" TEXT NOT NULL,
    "glasses" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "water_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."workout_entries" (
    "id" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "date" TEXT NOT NULL,
    "exerciseName" TEXT NOT NULL,
    "muscleGroup" TEXT,
    "durationMinutes" DOUBLE PRECISION,
    "sets" INTEGER,
    "reps" INTEGER,
    "weightKg" DOUBLE PRECISION,
    "caloriesBurned" DOUBLE PRECISION NOT NULL,
    "isEstimated" BOOLEAN NOT NULL DEFAULT false,
    "sourceText" TEXT,
    "estimationMeta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workout_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nutrition"."workout_reactions" (
    "id" TEXT NOT NULL,
    "workoutEntryId" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "type" "nutrition"."ReactionType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "workout_reactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "nutrition"."users"("username");

-- CreateIndex
CREATE INDEX "users_username_idx" ON "nutrition"."users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_userId_key" ON "nutrition"."user_profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "foods_barcode_key" ON "nutrition"."foods"("barcode");

-- CreateIndex
CREATE INDEX "foods_name_idx" ON "nutrition"."foods"("name");

-- CreateIndex
CREATE INDEX "log_entries_date_idx" ON "nutrition"."log_entries"("date");

-- CreateIndex
CREATE INDEX "log_entries_userId_date_idx" ON "nutrition"."log_entries"("userId", "date");

-- CreateIndex
CREATE INDEX "log_entries_mealType_date_idx" ON "nutrition"."log_entries"("mealType", "date");

-- CreateIndex
CREATE INDEX "buddy_relationships_addresseeId_status_idx" ON "nutrition"."buddy_relationships"("addresseeId", "status");

-- CreateIndex
CREATE INDEX "buddy_relationships_requesterId_status_idx" ON "nutrition"."buddy_relationships"("requesterId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "buddy_relationships_requesterId_addresseeId_key" ON "nutrition"."buddy_relationships"("requesterId", "addresseeId");

-- CreateIndex
CREATE INDEX "reactions_logEntryId_idx" ON "nutrition"."reactions"("logEntryId");

-- CreateIndex
CREATE INDEX "reactions_userId_idx" ON "nutrition"."reactions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "reactions_logEntryId_userId_type_key" ON "nutrition"."reactions"("logEntryId", "userId", "type");

-- CreateIndex
CREATE INDEX "weight_entries_userId_date_idx" ON "nutrition"."weight_entries"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "weight_entries_userId_date_key" ON "nutrition"."weight_entries"("userId", "date");

-- CreateIndex
CREATE INDEX "water_entries_userId_date_idx" ON "nutrition"."water_entries"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "water_entries_userId_date_key" ON "nutrition"."water_entries"("userId", "date");

-- CreateIndex
CREATE INDEX "workout_entries_date_idx" ON "nutrition"."workout_entries"("date");

-- CreateIndex
CREATE INDEX "workout_entries_userId_date_idx" ON "nutrition"."workout_entries"("userId", "date");

-- CreateIndex
CREATE INDEX "workout_reactions_workoutEntryId_idx" ON "nutrition"."workout_reactions"("workoutEntryId");

-- CreateIndex
CREATE INDEX "workout_reactions_userId_idx" ON "nutrition"."workout_reactions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "workout_reactions_workoutEntryId_userId_type_key" ON "nutrition"."workout_reactions"("workoutEntryId", "userId", "type");

-- AddForeignKey
ALTER TABLE "nutrition"."user_profiles" ADD CONSTRAINT "user_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."log_entries" ADD CONSTRAINT "log_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."log_entries" ADD CONSTRAINT "log_entries_foodId_fkey" FOREIGN KEY ("foodId") REFERENCES "nutrition"."foods"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."buddy_relationships" ADD CONSTRAINT "buddy_relationships_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."buddy_relationships" ADD CONSTRAINT "buddy_relationships_addresseeId_fkey" FOREIGN KEY ("addresseeId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."reactions" ADD CONSTRAINT "reactions_logEntryId_fkey" FOREIGN KEY ("logEntryId") REFERENCES "nutrition"."log_entries"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."reactions" ADD CONSTRAINT "reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."weight_entries" ADD CONSTRAINT "weight_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."water_entries" ADD CONSTRAINT "water_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."workout_entries" ADD CONSTRAINT "workout_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."workout_reactions" ADD CONSTRAINT "workout_reactions_workoutEntryId_fkey" FOREIGN KEY ("workoutEntryId") REFERENCES "nutrition"."workout_entries"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "nutrition"."workout_reactions" ADD CONSTRAINT "workout_reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "nutrition"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;


using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FelloWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class ReplaceInterestCatalog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "SortOrder",
                table: "interests",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_interests_SortOrder",
                table: "interests",
                column: "SortOrder");

            migrationBuilder.Sql(
                """
                DELETE FROM event_interests;
                DELETE FROM user_interests;
                DELETE FROM interests;

                INSERT INTO interests ("Id", "Name", "SortOrder", "CreatedAt", "UpdatedAt") VALUES
                ('11111111-1111-1111-1111-111111110001', 'ІТ та розробка', 1, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110002', 'Маркетинг/Продажі', 2, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110003', 'HR та рекрутинг', 3, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110004', 'Дизайн та візуалізація', 4, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110005', 'Освіта та навчання', 5, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110006', 'Здоров''я та медицина', 6, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110007', 'Розвиток бізнесу', 7, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110008', 'Логістика та ритейл', 8, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-111111110009', 'Інвестиції та фінанси', 9, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'),
                ('11111111-1111-1111-1111-11111111000a', 'Мілітарі', 10, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC');
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_interests_SortOrder",
                table: "interests");

            migrationBuilder.DropColumn(
                name: "SortOrder",
                table: "interests");
        }
    }
}

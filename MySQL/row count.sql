SELECT
    table_rows "Rows Count"
FROM
    information_schema.tables
WHERE
    table_name="merchant_payment_method_fee_override"
AND
    table_schema="directopago";


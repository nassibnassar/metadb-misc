-- circ_log_search based on Wayne Schneider's port to Metadb

CREATE FUNCTION circ_log_search(
    barcode text)
RETURNS TABLE(
    user_barcode text,
    item_barcode text,
    object text,
    action text,
    date timestamptz,
    service_point text,
    source text,
    description text)
AS $$
SELECT cl.jsonb->>'userBarcode' AS user_barcode,
       items->>'itemBarcode' AS item_barcode,
       cl.jsonb->>'object' AS object,
       cl.jsonb->>'action' AS action,
       (cl.jsonb->>'date')::timestamptz AS date,
       spt.name AS service_point,
       cl.jsonb->>'source' AS source,
       cl.jsonb->>'description' AS description
    FROM folio_audit.circulation_logs cl
        CROSS JOIN LATERAL jsonb_array_elements(cl.jsonb->'items') items
        LEFT JOIN folio_inventory.service_point__t spt ON spt.id::text = cl.jsonb->>'servicePointId'
    WHERE items->>'itemBarcode' = barcode
    ORDER BY (cl.jsonb->>'date')::timestamptz DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;


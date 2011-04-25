CREATE OR REPLACE FUNCTION resync_id_sequences() RETURNS void AS $$
DECLARE
  current_table RECORD;
  sequence_name VARCHAR;
  id_present RECORD;
  max_id RECORD;
BEGIN
  FOR current_table IN SELECT * FROM information_schema.tables WHERE table_schema = 'public' LOOP
    SELECT COUNT(*) AS count INTO id_present
    FROM pg_attribute a INNER JOIN pg_class c 
      ON a.attrelid = c.oid 
    INNER JOIN pg_namespace n 
      ON c.relnamespace = n.oid 
    WHERE a.attnum > 0 
      AND n.nspname = 'public' 
      AND c.relname = current_table.table_name
      AND a.attname = 'id';
    IF id_present.count = 1 THEN
      sequence_name := pg_get_serial_sequence(current_table.table_name, 'id');
      IF sequence_name IS NOT NULL THEN
        EXECUTE 'SELECT MAX(id) AS max FROM ' || current_table.table_name INTO max_id;
        RAISE NOTICE 'Resetting % value to %', sequence_name, max_id.max;
        PERFORM setval(sequence_name, max_id.max + 1);
      END IF;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

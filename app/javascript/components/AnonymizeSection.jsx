import React, { useState } from "react";
import Modal from "react-modal";
import axios from "axios";
import Select from "react-select";

const dataTypes = [
  { value: "none", label: "None" },
  { value: "first_name", label: "FirstName" },
  { value: "last_name", label: "LastName" },
  { value: "full_name", label: "FullName" },
  { value: "date_time", label: "DateTime" },
  { value: "address", label: "Address" },
  { value: "city", label: "City" },
  { value: "zip_code", label: "ZipCode" },
  { value: "province", label: "Province" },
  { value: "phone", label: "Phone" },
  { value: "email", label: "Email" },
  { value: "big_decimal", label: "BigDecimal" },
  { value: "bool", label: "Boolean" },
  { value: "integer", label: "Integer" },
  { value: "float", label: "Float" },
  { value: "string", label: "RandomString" },
  { value: "url", label: "URL" },
];

const AnonymizeSection = ({
  database,
  currentTableName,
  currentTableColumns,
  currentTablePrimaryKey,
}) => {
  const [modalIsOpen, setIsOpen] = useState(false);
  const [anonymizeData, setAnonymizeData] = useState({});
  const [primaryKey, setPrimaryKey] = useState(currentTablePrimaryKey);

  const sendToAnonymize = async () => {
    const requestData = {
      database: {
        strategies: anonymizeData,
        table_name: currentTableName,
        primary_key: primaryKey,
      },
    };
    const response = await axios.post(
      `/database/${database.id}/anonymize`,
      requestData
    );
    if (response.data.success) {
      window.location.href = "/";
    }
  };

  const handleSelect = (value, columnName) => {
    const updatedData = { ...anonymizeData };
    updatedData[columnName] = value.value;
    if (value.value === "none") {
      delete updatedData[columnName];
    }
    setAnonymizeData(updatedData);
  };

  const primaryKeyOptions = currentTableColumns.map((item) => ({
    value: item,
    label: item,
  }));

  return (
    <div className="mb-3">
      <button onClick={() => setIsOpen(true)} className="btn btn-primary">
        Start Anonymization
      </button>
      <Modal
        isOpen={modalIsOpen}
        onRequestClose={() => setIsOpen(false)}
        contentLabel="Example Modal"
        ariaHideApp={false}
      >
        <h2 className="text-center">
          Anonymize table <span className="fst-italic">{currentTableName}</span>
        </h2>

        <div>
          <h5>
            System checking Primary key for this table -{" "}
            {currentTablePrimaryKey}
          </h5>
          <span>Please reselect this value if you find some mismatch</span>
          <Select
            defaultValue={primaryKeyOptions.find(
              (keyOption) => keyOption.value === primaryKey
            )}
            options={primaryKeyOptions}
            onChange={(primaryKey) => setPrimaryKey(primaryKey.value)}
            components={{ IndicatorSeparator: () => null }}
          />
        </div>
        <table className="table">
          <thead>
            <tr>
              <th scope="col">Column name</th>
              <th scope="col">Anonymization type</th>
            </tr>
          </thead>
          <tbody>
            {currentTableColumns.map((columnName) => (
              <tr key={columnName}>
                <td className="mr-3">{columnName}</td>
                <td>
                  <Select
                    defaultValue={dataTypes[0]}
                    isSearchable
                    options={dataTypes}
                    onChange={(value) => handleSelect(value, columnName)}
                    components={{ IndicatorSeparator: () => null }}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        <button className="btn-danger btn" onClick={() => sendToAnonymize()}>
          Anonymize
        </button>
      </Modal>
    </div>
  );
};

export default AnonymizeSection;

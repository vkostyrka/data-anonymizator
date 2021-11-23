import React, { useState } from "react";
import Modal from "react-modal";
import axios from "axios";
import Select from "react-select";

const dataTypes = [
  { value: "none", label: "None" },
  { value: "first_name", label: "FirstName" },
  { value: "last_name", label: "LastName" },
  { value: "date_time", label: "DateTime" },
  { value: "address", label: "Address" },
  { value: "city", label: "City" },
  { value: "zip_code", label: "ZipCode" },
  { value: "phone", label: "Phone" },
  { value: "email", label: "Email" },
];

const AnonymizeSection = ({
  database,
  currentTableName,
  currentTableColumns,
}) => {
  const [modalIsOpen, setIsOpen] = useState(false);
  const [anonymizeData, setAnonymizeData] = useState({});

  console.log(anonymizeData);

  const sendToAnonymize = async () => {
    const response = await axios.post(`/database/${database.id}/anonymize`);
    if (response.data.success) {
      window.location.href = "/";
    }
  };

  const handleSelect = (value, columnName) => {
    const updatedData = { ...anonymizeData };
    updatedData[columnName] = value.value;
    setAnonymizeData(updatedData);
  };

  return (
    <div>
      <button onClick={() => setIsOpen(true)} className="btn btn-info">
        Start Anonymization
      </button>
      <Modal
        isOpen={modalIsOpen}
        onRequestClose={() => setIsOpen(false)}
        contentLabel="Example Modal"
        ariaHideApp={false}
      >
        <div>Anonymize table {currentTableName}</div>

        {currentTableColumns.map((columnName) => (
          <div className="my-3 d-flex align-items-center" key={columnName}>
            <div className="mr-3">{columnName}</div>
            <div>
              <Select
                defaultValue={dataTypes[0]}
                isSearchable
                options={dataTypes}
                onChange={(value) => handleSelect(value, columnName)}
                components={{ IndicatorSeparator: () => null }}
              />
            </div>
          </div>
        ))}

        <button className="btn-danger btn" onClick={() => sendToAnonymize()}>
          Anonymize
        </button>
      </Modal>
    </div>
  );
};

export default AnonymizeSection;

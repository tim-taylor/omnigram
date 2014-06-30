class DataField {
  
  String  m_description;  // text description of the data in this field
  char    m_type;         // 'F' float, 'I' int, 'S' string
  boolean m_bTarget;      // is this a target (output) field?
  boolean m_bIgnore;      // should this field be ignored?
  int     m_dataIdx;      // the corresponding column index in Data.m_data
 
  protected float m_fMin; // these are protected because of the scope
  protected float m_fMax; // for confusion between int and float versions.
  protected int   m_iMin; // Use the accessors iMin(), iMax(), iRange()
  protected int   m_iMax; // and corresponding f versions.
 
  DataField() {
    setDefaults();
  }
  
  DataField(String desc, char type) {
    setDefaults();
    m_description = desc;
    m_type = type;
  }  
  
  DataField(String desc, char type, boolean target) {
    setDefaults();
    m_description = desc;
    m_type = type;
    m_bTarget = target;
  }  
  
  DataField(String desc, char type, boolean target, boolean ignore) {
    setDefaults();    
    m_description = desc;
    m_type = type;
    m_bTarget = target;
    m_bIgnore = ignore;
  }
  
  void setDefaults() {
    m_type = 'F';
    m_bTarget = false;
    m_bIgnore = false;
    m_fMin = 99999.9;
    m_fMax = -99999.9;
    m_iMin = 99999;
    m_iMax = -99999;
    m_dataIdx = -1;
  }
  
  boolean isActiveInput() {
    return ((!m_bTarget) && (!m_bIgnore));
  }
  
  boolean isTarget() {
    return m_bTarget;
  }
  
  boolean isInt() {
    return (m_type == 'I');
  }
  
  boolean isFloat() {
    return (m_type == 'F');
  }
  
  boolean isString() {
    return (m_type == 'S');
  }
  
  int iMin() {
    return m_iMin;
  }
  
  int iMax() {
    return m_iMax;
  }
  
  int iRange() {
    return 1+(m_iMax - m_iMin);
  }
  
  float fMin() {
    return m_fMin;
  }
  
  float fMax() {
    return m_fMax;
  }
  
  float fRange() {
    return (m_fMax - m_fMin);
  }
  
  String toString() {
    String str;
    str = m_description + " " + m_type + " " + m_bTarget + " " + m_bIgnore + " f(" + 
          m_fMin + "," + m_fMax + ") i(" + m_iMin + "," + m_iMax + ") " + m_dataIdx;
    return str;
  }

}
